enum HapticImpactStyle: String, CaseIterable, Sendable {
    case light, medium, heavy, soft, rigid
}

enum HapticNotificationType: String, CaseIterable, Sendable {
    case success, warning, error
}

/// A sequence of transient pulses, independent of CoreHaptics.
struct HapticPattern: Equatable, Sendable {
    struct Event: Equatable, Sendable {
        let relativeTime: Double
        let intensity: Float
        let sharpness: Float
    }

    let events: [Event]

    static let demo = HapticPattern(events: [
        Event(relativeTime: 0, intensity: 0.4, sharpness: 0.3),
        Event(relativeTime: 0.2, intensity: 0.7, sharpness: 0.6),
        Event(relativeTime: 0.4, intensity: 1, sharpness: 1)
    ])
}

@MainActor
protocol HapticsPlaying {
    var supportsCustomHaptics: Bool { get }
    func impact(style: HapticImpactStyle)
    func notification(type: HapticNotificationType)
    func selection()
    func playPattern(_ pattern: HapticPattern)
}
