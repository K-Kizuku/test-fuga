import SwiftUI

@MainActor
struct TapHistoryCapabilityView: View {
    @State private var model: TapHistoryModel

    init(model: TapHistoryModel = TapHistoryModel()) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button("ダミー回数を記録", action: model.recordDummy)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("tap-history-record")
                .padding()

            if model.isEmpty {
                ContentUnavailableView(
                    "履歴がありません",
                    systemImage: "clock",
                    description: Text("記録ボタンでダミーのタップ回数を追加できます。")
                )
                .accessibilityIdentifier("tap-history-empty")
            } else {
                List(model.entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(entry.count) 回")
                            .font(.headline)
                        Text(entry.date, format: .dateTime)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("tap-history-entry-\(entry.id)")
                }
                .accessibilityIdentifier("tap-history-list")
            }

            Button("全消去", role: .destructive, action: model.clear)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(model.isEmpty)
                .accessibilityIdentifier("tap-history-clear")
                .padding()
        }
    }
}

#Preview("Mock history") {
    TapHistoryCapabilityView(model: TapHistoryModel(store: InMemoryTapHistoryStore(entries: [
        TapHistoryEntry(id: UUID(), date: Date(timeIntervalSince1970: 1_700_000_000), count: 12),
        TapHistoryEntry(id: UUID(), date: Date(timeIntervalSince1970: 1_700_003_600), count: 34)
    ])))
}

#Preview("Empty history") {
    TapHistoryCapabilityView(model: TapHistoryModel(store: InMemoryTapHistoryStore()))
}
