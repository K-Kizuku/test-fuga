import Foundation
import Observation

@MainActor
@Observable
final class TapHistoryModel {
    private let store: any TapHistoryStoring
    private let now: () -> Date
    private(set) var entries: [TapHistoryEntry]

    init(store: any TapHistoryStoring = UserDefaultsTapHistoryStore(), now: @escaping () -> Date = Date.init) {
        self.store = store
        self.now = now
        entries = store.entries
    }

    var isEmpty: Bool { entries.isEmpty }

    func recordDummy() {
        store.record(count: Int.random(in: 1...99), date: now())
        entries = store.entries
    }

    func clear() {
        store.clear()
        entries = store.entries
    }
}
