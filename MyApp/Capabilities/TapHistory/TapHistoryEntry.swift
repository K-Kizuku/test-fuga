import Foundation

struct TapHistoryEntry: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let count: Int
}
