import SwiftUI

@MainActor
struct DeviceOrientationCapabilityView: View {
    @State private var model = DeviceOrientationModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(model.orientation.displayName, systemImage: model.orientation.systemImageName)
                    .font(.title)
                    .accessibilityIdentifier("device-orientation-current")

                Text(classification)
                    .accessibilityIdentifier("device-orientation-classification")

                if model.orientation == .unknown {
                    Text("端末の向きをまだ取得できません。端末を持ち上げて向きを変えてください。Mock でも各向きを確認できます。")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("device-orientation-unknown")
                }

                Toggle("Mock を使用", isOn: Binding(
                    get: { model.isUsingMock },
                    set: { model.setUsingMock($0) }
                ))
                .accessibilityIdentifier("device-orientation-mock-toggle")

                if model.isUsingMock {
                    ForEach(DeviceOrientationKind.allCases, id: \.self) { kind in
                        Button {
                            model.selectMock(kind)
                        } label: {
                            Label(kind.displayName, systemImage: kind.systemImageName)
                        }
                        .accessibilityIdentifier("device-orientation-mock-\(kind.rawValue)")
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear { model.start() }
        .onDisappear { model.stop() }
    }

    private var classification: String {
        if model.orientation.isPortrait {
            "縦"
        } else if model.orientation.isLandscape {
            "横"
        } else {
            "縦でも横でもない（平置き・不明）"
        }
    }
}
