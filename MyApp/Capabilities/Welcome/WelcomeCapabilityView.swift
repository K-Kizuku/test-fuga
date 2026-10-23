import SwiftUI

struct WelcomeCapabilityView: View {
    @State private var text = ""
    var body: some View {
        Form {
            Text("Add an independent capability, then register it in CapabilityRegistry.")
            TextField("Template smoke check", text: $text)
            Text(text.isEmpty ? "Ready" : text).accessibilityIdentifier("template-output")
        }
    }
}
