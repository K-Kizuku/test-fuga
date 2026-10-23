import Foundation
import XCTest
@testable import HackathonApp

final class TapHistoryTests: XCTestCase {
    @MainActor
    func testInMemoryRecordsCountAndDate() throws {
        let store = InMemoryTapHistoryStore()
        XCTAssertTrue(store.entries.isEmpty)
        let date = Date(timeIntervalSince1970: 100)

        store.record(count: 12, date: date)

        XCTAssertEqual(store.entries.count, 1)
        let entry = try XCTUnwrap(store.entries.first)
        XCTAssertEqual(entry.count, 12)
        XCTAssertEqual(entry.date, date)
    }

    @MainActor
    func testStoresReturnNewestEntriesFirst() throws {
        try withIsolatedDefaults { defaults in
            let stores: [any TapHistoryStoring] = [
                InMemoryTapHistoryStore(),
                UserDefaultsTapHistoryStore(defaults: defaults)
            ]
            for store in stores {
                store.record(count: 1, date: Date(timeIntervalSince1970: 100))
                store.record(count: 3, date: Date(timeIntervalSince1970: 300))
                store.record(count: 2, date: Date(timeIntervalSince1970: 200))

                XCTAssertEqual(store.entries.map(\.count), [3, 2, 1])
                XCTAssertEqual(store.entries.map(\.date), [300, 200, 100].map { Date(timeIntervalSince1970: $0) })
                XCTAssertEqual(Set(store.entries.map(\.id)).count, 3)
            }
        }
    }

    @MainActor
    func testUserDefaultsRestoresEntriesAfterRecreation() throws {
        try withIsolatedDefaults { defaults in
            let store = UserDefaultsTapHistoryStore(defaults: defaults)
            XCTAssertTrue(store.entries.isEmpty)
            store.record(count: 12, date: Date(timeIntervalSince1970: 100))
            store.record(count: 34, date: Date(timeIntervalSince1970: 200))

            let restored = UserDefaultsTapHistoryStore(defaults: defaults)

            XCTAssertEqual(restored.entries, store.entries)
            XCTAssertEqual(restored.entries.map(\.count), [34, 12])
        }
    }

    @MainActor
    func testInMemoryClearRemovesEntries() {
        let store = InMemoryTapHistoryStore()
        store.record(count: 12, date: Date(timeIntervalSince1970: 100))

        store.clear()

        XCTAssertTrue(store.entries.isEmpty)
    }

    @MainActor
    func testUserDefaultsClearRemainsEmptyAfterRecreation() throws {
        try withIsolatedDefaults { defaults in
            let store = UserDefaultsTapHistoryStore(defaults: defaults)
            store.record(count: 12, date: Date(timeIntervalSince1970: 100))

            store.clear()

            XCTAssertTrue(store.entries.isEmpty)
            XCTAssertTrue(UserDefaultsTapHistoryStore(defaults: defaults).entries.isEmpty)
        }
    }

    @MainActor
    func testInvalidJSONLoadsAsEmpty() throws {
        try withIsolatedDefaults { defaults in
            let key = "invalid-history"
            defaults.set(Data("invalid JSON".utf8), forKey: key)

            let store = UserDefaultsTapHistoryStore(defaults: defaults, key: key)

            XCTAssertTrue(store.entries.isEmpty)
            store.record(count: 12, date: Date(timeIntervalSince1970: 100))
            XCTAssertEqual(UserDefaultsTapHistoryStore(defaults: defaults, key: key).entries, store.entries)
            XCTAssertEqual(store.entries.count, 1)
        }
    }

    @MainActor
    func testModelRecordsUsingInjectedTimeAndClears() throws {
        let store = InMemoryTapHistoryStore()
        let date = Date(timeIntervalSince1970: 100)
        let model = TapHistoryModel(store: store, now: { date })
        XCTAssertTrue(model.isEmpty)

        model.recordDummy()

        XCTAssertFalse(model.isEmpty)
        XCTAssertEqual(model.entries.count, 1)
        let entry = try XCTUnwrap(model.entries.first)
        XCTAssertEqual(entry.date, date)
        XCTAssertTrue((1...99).contains(entry.count))
        XCTAssertEqual(model.entries, store.entries)

        model.clear()

        XCTAssertTrue(model.isEmpty)
        XCTAssertTrue(model.entries.isEmpty)
        XCTAssertTrue(store.entries.isEmpty)
    }

    @MainActor
    func testModelLoadsExistingEntries() {
        let entry = TapHistoryEntry(id: UUID(), date: Date(timeIntervalSince1970: 100), count: 12)
        let model = TapHistoryModel(store: InMemoryTapHistoryStore(entries: [entry]))

        XCTAssertEqual(model.entries, [entry])
        XCTAssertFalse(model.isEmpty)
    }

    @MainActor
    func testTapHistoryIsRegistered() throws {
        let entry = try XCTUnwrap(CapabilityRegistry.entries.first { $0.id == CapabilityID.tapHistory })

        XCTAssertTrue(CapabilityID.isValid(entry.id))
        XCTAssertEqual(entry.title, "Tap History")
        XCTAssertFalse(entry.deviceChecks.isEmpty)
        _ = entry.makeView()
    }

    @MainActor
    private func withIsolatedDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let suiteName = "TapHistoryTests-\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try body(defaults)
    }
}
