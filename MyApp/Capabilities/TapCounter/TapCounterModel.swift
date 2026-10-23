import Observation

@MainActor
@Observable
final class TapCounterModel {
    private var counter: any TapCounting

    init(counter: any TapCounting = TapCounter()) {
        self.counter = counter
    }

    var count: Int { counter.count }

    func tap() {
        counter.increment()
    }

    func reset() {
        counter.reset()
    }
}
