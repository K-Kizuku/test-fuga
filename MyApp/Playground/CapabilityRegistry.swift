import SwiftUI

/// Add one entry per independent capability. Include this shared file in the Issue scope.
@MainActor
struct CapabilityEntry: Identifiable {
    let id: String
    let title: String
    let deviceChecks: String
    let makeView: () -> AnyView
}

@MainActor
enum CapabilityRegistry {
    static let entries: [CapabilityEntry] = [
        CapabilityEntry(id: "welcome", title: "Template check", deviceChecks: "No hardware needed") {
            AnyView(WelcomeCapabilityView())
        }
    ]
}
