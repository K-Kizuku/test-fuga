import Foundation
import XCTest
@testable import HackathonApp

final class TapCounterHistoryIntegrationTests: XCTestCase {
    @MainActor
    func testResetRecordsPreviousCountAndDate() throws {
        let store = InMemoryTapHistoryStore()
        let date = Date(timeIntervalSince1970: 100)
        let model = TapCounterModel(history: store, now: { date })
        for _ in 0..<3 {
            model.tap()
        }

        model.reset()

        XCTAssertEqual(store.entries.count, 1)
        let entry = try XCTUnwrap(store.entries.first)
        XCTAssertEqual(entry.count, 3)
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(model.count, 0)
        XCTAssertEqual(model.historyEntries, store.entries)
    }

    @MainActor
    func testResetAtZeroDoesNotRecord() {
        let store = InMemoryTapHistoryStore()
        let model = TapCounterModel(history: store)

        model.reset()

        XCTAssertTrue(store.entries.isEmpty)
        XCTAssertTrue(model.historyEntries.isEmpty)
        XCTAssertEqual(model.count, 0)
    }

    @MainActor
    func testMultipleResetsAreNewestFirst() {
        let store = InMemoryTapHistoryStore()
        var date = Date(timeIntervalSince1970: 100)
        let model = TapCounterModel(history: store, now: { date })
        for _ in 0..<2 {
            model.tap()
        }
        model.reset()

        date = Date(timeIntervalSince1970: 200)
        for _ in 0..<5 {
            model.tap()
        }
        model.reset()

        XCTAssertEqual(model.historyEntries.map(\.count), [5, 2])
        XCTAssertEqual(model.historyEntries.map(\.date), [date, Date(timeIntervalSince1970: 100)])
        XCTAssertEqual(model.historyEntries, store.entries)
        XCTAssertEqual(model.count, 0)
    }

    @MainActor
    func testModelLoadsExistingHistory() {
        let entry = TapHistoryEntry(id: UUID(), date: Date(timeIntervalSince1970: 100), count: 12)
        let store = InMemoryTapHistoryStore(entries: [entry])

        let model = TapCounterModel(history: store)

        XCTAssertEqual(model.historyEntries, [entry])
        XCTAssertEqual(model.count, 0)
    }

    @MainActor
    func testUserDefaultsHistoryPersistsAcrossModelRecreation() throws {
        let suiteName = "TapCounterHistoryIntegrationTests-\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = UserDefaultsTapHistoryStore(defaults: defaults)
        let date = Date(timeIntervalSince1970: 100)
        let model = TapCounterModel(history: store, now: { date })
        for _ in 0..<3 {
            model.tap()
        }
        model.reset()

        let restoredStore = UserDefaultsTapHistoryStore(defaults: defaults)
        let restoredModel = TapCounterModel(history: restoredStore)

        XCTAssertEqual(restoredStore.entries.count, 1)
        XCTAssertEqual(restoredModel.historyEntries, model.historyEntries)
        let entry = try XCTUnwrap(restoredModel.historyEntries.first)
        XCTAssertEqual(entry.count, 3)
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(restoredModel.count, 0)
    }

    @MainActor
    func testCounterViewCanBeCreatedWithInjectedModel() {
        let model = TapCounterModel(history: InMemoryTapHistoryStore())

        _ = TapCounterCapabilityView(model: model)
    }
}
