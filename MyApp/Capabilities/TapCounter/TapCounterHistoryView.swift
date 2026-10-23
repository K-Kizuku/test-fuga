import SwiftUI

@MainActor
struct TapCounterHistoryView: View {
    let entries: [TapHistoryEntry]

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    "履歴がありません",
                    systemImage: "clock",
                    description: Text("タップしてからリセットすると、回数と日時が記録されます。")
                )
                .accessibilityIdentifier("tap-counter-history-empty")
            } else {
                List(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(entry.count) 回")
                            .font(.headline)
                        Text(entry.date.formatted(.dateTime))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
                .accessibilityIdentifier("tap-counter-history-list")
            }
        }
        .navigationTitle("リセット履歴")
    }
}
