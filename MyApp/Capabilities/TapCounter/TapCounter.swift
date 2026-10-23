protocol TapCounting {
    var count: Int { get }
    mutating func increment()
    mutating func reset()
}

struct TapCounter: TapCounting, Sendable {
    private(set) var count = 0

    mutating func increment() {
        guard count < Int.max else { return }
        count += 1
    }

    mutating func reset() {
        count = 0
    }
}
