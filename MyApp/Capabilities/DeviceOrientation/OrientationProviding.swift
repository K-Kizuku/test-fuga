enum DeviceOrientationKind: String, CaseIterable, Sendable {
    case portrait, portraitUpsideDown, landscapeLeft, landscapeRight
    case faceUp, faceDown, unknown

    var isPortrait: Bool {
        self == .portrait || self == .portraitUpsideDown
    }

    var isLandscape: Bool {
        self == .landscapeLeft || self == .landscapeRight
    }

    var displayName: String {
        switch self {
        case .portrait: "縦向き"
        case .portraitUpsideDown: "縦向き（上下逆）"
        case .landscapeLeft: "横向き（左）"
        case .landscapeRight: "横向き（右）"
        case .faceUp: "平置き（画面が上）"
        case .faceDown: "平置き（画面が下）"
        case .unknown: "不明"
        }
    }

    var systemImageName: String {
        switch self {
        case .portrait, .portraitUpsideDown: "iphone"
        case .landscapeLeft, .landscapeRight: "iphone.landscape"
        case .faceUp: "rectangle.portrait"
        case .faceDown: "rectangle.portrait.fill"
        case .unknown: "questionmark.circle"
        }
    }
}

@MainActor
protocol OrientationProviding: AnyObject {
    var currentOrientation: DeviceOrientationKind { get }
    var onChange: ((DeviceOrientationKind) -> Void)? { get set }
    func start()
    func stop()
}
