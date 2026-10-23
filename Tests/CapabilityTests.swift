import XCTest
@testable import HackathonApp

final class CapabilityTests: XCTestCase {
    @MainActor
    func testRegistryHasUniqueUsableEntries() {
        let entries = CapabilityRegistry.entries
        XCTAssertFalse(entries.isEmpty)
        XCTAssertEqual(Set(entries.map(\.id)).count, entries.count)
        for entry in entries {
            XCTAssertTrue(CapabilityID.isValid(entry.id))
            XCTAssertFalse(entry.title.isEmpty)
            _ = entry.makeView()
        }
    }

    func testRejectsInvalidCapabilityID() {
        XCTAssertFalse(CapabilityID.isValid(""))
        XCTAssertFalse(CapabilityID.isValid("camera/photo"))
        XCTAssertTrue(CapabilityID.isValid("camera-photo"))
    }
}
