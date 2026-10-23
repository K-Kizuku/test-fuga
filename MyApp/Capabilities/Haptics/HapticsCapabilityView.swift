import SwiftUI

@MainActor
struct HapticsCapabilityView: View {
    @State private var model = HapticsModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Impact")
                    .font(.headline)
                ForEach(HapticImpactStyle.allCases, id: \.self) { style in
                    Button("Impact: \(style.rawValue)") {
                        model.impact(style)
                    }
                    .accessibilityIdentifier("haptics-impact-\(style.rawValue)")
                }

                Text("Notification")
                    .font(.headline)
                ForEach(HapticNotificationType.allCases, id: \.self) { type in
                    Button("Notification: \(type.rawValue)") {
                        model.notify(type)
                    }
                    .accessibilityIdentifier("haptics-notification-\(type.rawValue)")
                }

                Button("Selection", action: model.select)
                    .accessibilityIdentifier("haptics-selection")

                Button("Custom pattern", action: model.playCustomPattern)
                    .disabled(!model.supportsCustomHaptics)
                    .accessibilityIdentifier("haptics-custom-pattern")

                if !model.supportsCustomHaptics {
                    Text("この端末はカスタムハプティクス非対応です。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("haptics-unsupported")
                }

                Text(model.lastAction)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("haptics-last-action")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
