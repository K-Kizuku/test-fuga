import SwiftUI

@MainActor
struct TapCounterCapabilityView: View {
    @State private var model = TapCounterModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tap count")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("\(model.count)")
                    .font(.system(.largeTitle, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Tap count")
                    .accessibilityValue(Text("\(model.count)"))
                    .accessibilityIdentifier("tap-counter-count")

                Button(action: model.tap) {
                    Text("Tap")
                        .font(.title2)
                        .frame(maxWidth: .infinity, minHeight: 88)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("tap-counter-tap")

                Button("Reset", action: model.reset)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityIdentifier("tap-counter-reset")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
