@MainActor
final class MockHapticsPlayer: HapticsPlaying {
    enum Call: Equatable, Sendable {
        case impact(HapticImpactStyle)
        case notification(HapticNotificationType)
        case selection
        case pattern(HapticPattern)
    }

    let supportsCustomHaptics: Bool
    private(set) var calls: [Call] = []

    init(supportsCustomHaptics: Bool = false) {
        self.supportsCustomHaptics = supportsCustomHaptics
    }

    func impact(style: HapticImpactStyle) {
        calls.append(.impact(style))
    }

    func notification(type: HapticNotificationType) {
        calls.append(.notification(type))
    }

    func selection() {
        calls.append(.selection)
    }

    func playPattern(_ pattern: HapticPattern) {
        calls.append(.pattern(pattern))
    }
}
