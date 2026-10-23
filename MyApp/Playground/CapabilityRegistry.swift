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
        },
        CapabilityEntry(id: "tap-counter", title: "Tap Counter", deviceChecks: "No hardware needed (check rapid taps on device)") {
            AnyView(TapCounterCapabilityView())
        },
        CapabilityEntry(id: CapabilityID.haptics, title: "Haptics", deviceChecks: "Physical iPhone required (Impact/Notification/Selection/custom pattern, foreground resume)") {
            AnyView(HapticsCapabilityView())
        },
        CapabilityEntry(id: CapabilityID.tapHistory, title: "Tap History", deviceChecks: "No hardware needed (check persistence after relaunch, locale/timezone, Dark Mode, large Dynamic Type)") {
            AnyView(TapHistoryCapabilityView())
        },
        CapabilityEntry(id: CapabilityID.deviceOrientation, title: "Device Orientation", deviceChecks: "Physical iPhone required (portrait/landscape/upside down, faceUp/faceDown, rotation lock, stop on close)") {
            AnyView(DeviceOrientationCapabilityView())
        }
    ]
}
