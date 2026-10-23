import Foundation
import Observation

@MainActor
@Observable
final class TapCounterModel {
    private var counter: any TapCounting
    private let history: any TapHistoryStoring
    private let now: () -> Date
    private(set) var historyEntries: [TapHistoryEntry]

    init(
        counter: any TapCounting = TapCounter(),
        history: any TapHistoryStoring = UserDefaultsTapHistoryStore(),
        now: @escaping () -> Date = Date.init
    ) {
        self.counter = counter
        self.history = history
        self.now = now
        historyEntries = history.entries
    }

    var count: Int { counter.count }

    func tap() {
        counter.increment()
    }

    func reset() {
        let previous = counter.count
        if previous > 0 {
            history.record(count: previous, date: now())
        }
        counter.reset()
        historyEntries = history.entries
    }
}
