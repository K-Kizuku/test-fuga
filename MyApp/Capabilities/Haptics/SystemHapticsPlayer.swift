import CoreHaptics
import UIKit

@MainActor
final class SystemHapticsPlayer: HapticsPlaying {
    let supportsCustomHaptics: Bool
    private var impactGenerators: [HapticImpactStyle: UIImpactFeedbackGenerator] = [:]
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private var engine: CHHapticEngine?
    private var patternPlayer: (any CHHapticPatternPlayer)?
    private var foregroundObservation: HapticsForegroundObservation?

    init() {
        supportsCustomHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsCustomHaptics else { return }

        foregroundObservation = HapticsForegroundObservation { [weak self] in
            Task { @MainActor [weak self] in
                self?.startEngine()
            }
        }
        startEngine()
    }

    func impact(style: HapticImpactStyle) {
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = switch style {
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        case .soft: .soft
        case .rigid: .rigid
        }
        let generator = impactGenerators[style] ?? UIImpactFeedbackGenerator(style: feedbackStyle)
        impactGenerators[style] = generator
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(type: HapticNotificationType) {
        let feedbackType: UINotificationFeedbackGenerator.FeedbackType = switch type {
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(feedbackType)
    }

    func selection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    func playPattern(_ pattern: HapticPattern) {
        guard supportsCustomHaptics else { return }
        startEngine()
        guard let engine else { return }

        do {
            let events = pattern.events.map { event in
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: event.intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: event.sharpness)
                ], relativeTime: event.relativeTime)
            }
            let hapticPattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: hapticPattern)
            try player.start(atTime: CHHapticTimeImmediate)
            patternPlayer = player
        } catch {
            // Hardware interruptions and invalid patterns must not crash the Playground.
            patternPlayer = nil
        }
    }

    private func startEngine() {
        guard supportsCustomHaptics else { return }
        do {
            if engine == nil {
                let newEngine = try CHHapticEngine()
                // CoreHaptics invokes these handlers off the main actor.
                newEngine.resetHandler = { @Sendable [weak self] in
                    Task { @MainActor [weak self] in
                        self?.patternPlayer = nil
                        self?.startEngine()
                    }
                }
                newEngine.stoppedHandler = { @Sendable [weak self] reason in
                    Task { @MainActor [weak self] in
                        self?.patternPlayer = nil
                        // Suspension is recovered by the foreground observer; do not
                        // restart the engine while the application is in the background.
                        guard reason != .applicationSuspended,
                              UIApplication.shared.applicationState == .active else { return }
                        self?.startEngine()
                    }
                }
                engine = newEngine
            }
            try engine?.start()
        } catch {
            // A foreground transition or the next pattern request can retry.
            patternPlayer = nil
        }
    }
}

/// Owns the observer token so removal does not require a MainActor-isolated deinit.
private final class HapticsForegroundObservation {
    private let token: any NSObjectProtocol

    @MainActor
    init(onForeground: @escaping @Sendable () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            onForeground()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(token)
    }
}
