#!/usr/bin/env node
import { spawn } from "node:child_process";
import { mkdir, writeFile, readFile, rm, stat } from "node:fs/promises";
import { resolve, join } from "node:path";
import { tmpdir, homedir, userInfo } from "node:os";
import { createWriteStream } from "node:fs";
import { createHash } from "node:crypto";
if (process.platform !== "darwin") {
  console.error("macOS + Xcode required. No iOS checks executed.");
  process.exit(1);
}
// TAKT command gates pass only PATH/SHELL/TMPDIR; Xcode and CoreSimulator need HOME,
// and XcodeGen aborts with "Couldn't find current username" without USER.
const user = userInfo().username;
const env = {
  ...process.env,
  HOME: process.env.HOME || homedir(),
  USER: process.env.USER || user,
  LOGNAME: process.env.LOGNAME || user,
};
const cwd = process.cwd(),
  logs = resolve(".build-logs"),
  derived = process.env.HACK_DERIVED_DATA
    ? resolve(
        process.env.HACK_DERIVED_DATA,
        createHash("sha256").update(cwd).digest("hex").slice(0, 16),
      )
    : resolve("DerivedData");
await mkdir(logs, { recursive: true });
const stamp = new Date().toISOString().replaceAll(":", "-");
await writeFile(
  join(logs, "latest-result.json"),
  JSON.stringify({ passed: false, at: stamp, cwd, deviceVerified: false }),
);
async function run(cmd, args, name) {
  const log = createWriteStream(join(logs, `${stamp}-${name}.log`));
  return new Promise((ok, fail) => {
    const child = spawn(cmd, args, { cwd, env, shell: false });
    let out = "";
    const timer = setTimeout(() => {
      child.kill("SIGTERM");
      setTimeout(() => child.kill("SIGKILL"), 5000).unref();
    }, 1200000);
    child.stdout.on("data", (b) => {
      out += b;
      log.write(b);
      process.stdout.write(b);
    });
    child.stderr.on("data", (b) => {
      log.write(b);
      process.stderr.write(b);
    });
    child.once("error", (e) => {
      clearTimeout(timer);
      log.end();
      fail(
        e.code === "ENOENT"
          ? new Error(
              `${cmd} not found in PATH. Install it (brew install xcodegen / full Xcode) and retry.`,
            )
          : e,
      );
    });
    // "close" waits for stdout to drain; "exit" can fire before the JSON tail arrives.
    child.once("close", (code) => {
      clearTimeout(timer);
      log.end();
      code === 0
        ? ok(out)
        : fail(new Error(`${cmd} exit ${code}. See ${logs}`));
    });
  });
}
// Serialize Simulator tests across clones to avoid two test runners fighting for one device.
const lock = join(tmpdir(), "hackctl-ios-test.lock");
let held = false;
async function acquire() {
  const start = Date.now();
  for (;;) {
    try {
      await mkdir(lock);
      await writeFile(join(lock, "pid"), String(process.pid));
      held = true;
      return;
    } catch (e) {
      if (e.code !== "EEXIST") throw e;
      let pid = NaN;
      try {
        pid = Number(await readFile(join(lock, "pid"), "utf8"));
      } catch {
        /* creator may be writing its pid */
      }
      let stale;
      if (Number.isSafeInteger(pid) && pid > 0) {
        try {
          process.kill(pid, 0);
          stale = false;
        } catch (err) {
          stale = err.code === "ESRCH";
        }
      } else {
        // No readable pid: the creator died before writing it unless the lock is brand new.
        const age = await stat(lock).then(
          (s) => Date.now() - s.mtimeMs,
          () => 0,
        );
        stale = age > 30000;
      }
      if (stale) {
        await rm(lock, { recursive: true, force: true });
        continue;
      }
      if (Date.now() - start > 600000)
        throw new Error("Simulator test lock timeout; inspect " + lock);
      await new Promise((r) => setTimeout(r, 1000));
    }
  }
}
try {
  await run("xcodegen", ["generate", "--spec", "project.yml"], "xcodegen");
  const base = [
    "-project",
    "HackathonApp.xcodeproj",
    "-scheme",
    "HackathonApp",
    "-configuration",
    "Debug",
    "-derivedDataPath",
    derived,
    "CODE_SIGNING_ALLOWED=NO",
  ];
  await run(
    "xcodebuild",
    [...base, "-destination", "generic/platform=iOS Simulator", "build"],
    "build",
  );
  await acquire();
  let destination = process.env.HACK_IOS_DESTINATION;
  if (!destination) {
    const list = JSON.parse(
      await run(
        "xcrun",
        ["simctl", "list", "devices", "available", "--json"],
        "devices",
      ),
    );
    const device = Object.values(list.devices)
      .flat()
      .find((d) => d.isAvailable && d.name.startsWith("iPhone"));
    if (!device)
      throw new Error(
        "Install an iPhone Simulator runtime or set HACK_IOS_DESTINATION",
      );
    destination = `platform=iOS Simulator,id=${device.udid}`;
  }
  await run(
    "xcodebuild",
    [
      ...base,
      "-destination",
      destination,
      "-resultBundlePath",
      join(logs, `${stamp}.xcresult`),
      "test",
    ],
    "test",
  );
  await writeFile(
    join(logs, "latest-result.json"),
    JSON.stringify(
      {
        passed: true,
        at: new Date().toISOString(),
        cwd,
        destination,
        deviceVerified: false,
      },
      null,
      2,
    ),
  );
  console.log(
    "XcodeGen, Simulator build and XCTest passed. Physical device checks remain.",
  );
} catch (e) {
  // The gate output is read by the fixing agent; a one-line cause beats a stack trace.
  console.error(`hack-ios failed: ${e.message}`);
  process.exitCode = 1;
} finally {
  if (held) await rm(lock, { recursive: true });
}
