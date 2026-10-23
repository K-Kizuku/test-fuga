import Foundation

@MainActor
protocol TapHistoryStoring {
    /// Recorded entries, ordered from newest to oldest.
    var entries: [TapHistoryEntry] { get }
    func record(count: Int, date: Date)
    func clear()
}
