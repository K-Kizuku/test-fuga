import Foundation

@MainActor
final class InMemoryTapHistoryStore: TapHistoryStoring {
    private(set) var entries: [TapHistoryEntry]

    init(entries: [TapHistoryEntry] = []) {
        self.entries = entries.sorted { $0.date > $1.date }
    }

    func record(count: Int, date: Date) {
        entries.append(TapHistoryEntry(id: UUID(), date: date, count: count))
        entries.sort { $0.date > $1.date }
    }

    func clear() {
        entries = []
    }
}
