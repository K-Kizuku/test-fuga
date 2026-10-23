import Observation

@MainActor
@Observable
final class DeviceOrientationModel {
    private let systemProvider: any OrientationProviding
    private let mockProvider: MockOrientationProvider
    private var isRunning = false
    private(set) var orientation: DeviceOrientationKind = .unknown
    private(set) var isUsingMock = false

    init(
        systemProvider: any OrientationProviding = SystemOrientationProvider(),
        mockProvider: MockOrientationProvider = MockOrientationProvider()
    ) {
        self.systemProvider = systemProvider
        self.mockProvider = mockProvider
    }

    private var provider: any OrientationProviding {
        isUsingMock ? mockProvider : systemProvider
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        provider.onChange = { [weak self] orientation in
            guard let self, self.isRunning else { return }
            self.orientation = orientation
        }
        provider.start()
        orientation = provider.currentOrientation
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        provider.onChange = nil
        provider.stop()
    }

    func setUsingMock(_ useMock: Bool) {
        guard isUsingMock != useMock else { return }
        let wasRunning = isRunning
        stop()
        isUsingMock = useMock
        if wasRunning {
            start()
        }
    }

    func selectMock(_ kind: DeviceOrientationKind) {
        setUsingMock(true)
        mockProvider.send(kind)
    }
}
