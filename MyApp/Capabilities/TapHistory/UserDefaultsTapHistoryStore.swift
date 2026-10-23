import Foundation

@MainActor
final class UserDefaultsTapHistoryStore: TapHistoryStoring {
    private let defaults: UserDefaults
    private let key: String
    private(set) var entries: [TapHistoryEntry]

    init(defaults: UserDefaults = .standard, key: String = "tap-history.entries") {
        self.defaults = defaults
        self.key = key
        if let data = defaults.data(forKey: key),
           let savedEntries = try? JSONDecoder().decode([TapHistoryEntry].self, from: data) {
            entries = savedEntries.sorted { $0.date > $1.date }
        } else {
            entries = []
        }
    }

    func record(count: Int, date: Date) {
        let updatedEntries = (entries + [TapHistoryEntry(id: UUID(), date: date, count: count)])
            .sorted { $0.date > $1.date }
        guard let data = try? JSONEncoder().encode(updatedEntries) else { return }
        defaults.set(data, forKey: key)
        entries = updatedEntries
    }

    func clear() {
        defaults.removeObject(forKey: key)
        entries = []
    }
}
