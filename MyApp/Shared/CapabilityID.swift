enum CapabilityID {
    static let haptics = "haptics"
    static let tapHistory = "tap-history"

    static func isValid(_ id: String) -> Bool {
        !id.isEmpty && id.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
    }
}
