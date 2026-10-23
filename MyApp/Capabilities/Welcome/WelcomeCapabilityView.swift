import SwiftUI

struct WelcomeCapabilityView: View {
    @State private var text = ""
    var body: some View {
        Form {
            Text("ハッカソン用のCapability Playgroundです")
            TextField("Template smoke check", text: $text)
            Text(text.isEmpty ? "Ready" : text).accessibilityIdentifier("template-output")
        }
    }
}
