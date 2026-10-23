import UIKit

@MainActor
final class SystemOrientationProvider: OrientationProviding {
    var onChange: ((DeviceOrientationKind) -> Void)?
    private var observer: (any NSObjectProtocol)?
    private var isRunning = false

    var currentOrientation: DeviceOrientationKind {
        Self.kind(for: UIDevice.current.orientation)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // NotificationCenter delivers this observer on the main queue.
            MainActor.assumeIsolated {
                guard let self, self.isRunning else { return }
                self.onChange?(self.currentOrientation)
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    static func kind(for orientation: UIDeviceOrientation) -> DeviceOrientationKind {
        switch orientation {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        case .landscapeLeft: .landscapeLeft
        case .landscapeRight: .landscapeRight
        case .faceUp: .faceUp
        case .faceDown: .faceDown
        case .unknown: .unknown
        @unknown default: .unknown
        }
    }
}
