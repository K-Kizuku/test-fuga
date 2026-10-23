import Observation

@MainActor
@Observable
final class HapticsModel {
    private let player: any HapticsPlaying
    private(set) var lastAction = "操作を選んでください。"

    init(player: any HapticsPlaying = HapticsModel.defaultPlayer()) {
        self.player = player
    }

    static func defaultPlayer() -> any HapticsPlaying {
        #if targetEnvironment(simulator)
        MockHapticsPlayer()
        #else
        SystemHapticsPlayer()
        #endif
    }

    var supportsCustomHaptics: Bool { player.supportsCustomHaptics }

    func impact(_ style: HapticImpactStyle) {
        player.impact(style: style)
        lastAction = "Impact: \(style.rawValue)"
    }

    func notify(_ type: HapticNotificationType) {
        player.notification(type: type)
        lastAction = "Notification: \(type.rawValue)"
    }

    func select() {
        player.selection()
        lastAction = "Selection"
    }

    func playCustomPattern() {
        guard supportsCustomHaptics else {
            lastAction = "カスタムハプティクスは非対応です。"
            return
        }
        player.playPattern(.demo)
        lastAction = "Custom pattern"
    }
}
