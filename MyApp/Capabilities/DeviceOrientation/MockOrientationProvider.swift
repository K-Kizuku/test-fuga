@MainActor
final class MockOrientationProvider: OrientationProviding {
    private(set) var currentOrientation: DeviceOrientationKind
    var onChange: ((DeviceOrientationKind) -> Void)?
    private(set) var isRunning = false
    private(set) var startCount = 0
    private(set) var stopCount = 0

    init(orientation: DeviceOrientationKind = .portrait) {
        currentOrientation = orientation
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        startCount += 1
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        stopCount += 1
    }

    func send(_ orientation: DeviceOrientationKind) {
        currentOrientation = orientation
        if isRunning {
            onChange?(orientation)
        }
    }
}
