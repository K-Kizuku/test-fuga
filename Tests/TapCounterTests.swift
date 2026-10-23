import XCTest
@testable import HackathonApp

final class TapCounterTests: XCTestCase {
    func testInitialCountIsZero() {
        XCTAssertEqual(TapCounter().count, 0)
    }

    func testIncrementAddsOne() {
        var counter = TapCounter()

        counter.increment()

        XCTAssertEqual(counter.count, 1)
    }

    func testMultipleIncrements() {
        var counter = TapCounter()

        for expectedCount in 1...5 {
            counter.increment()
            XCTAssertEqual(counter.count, expectedCount)
        }
    }

    func testResetReturnsToZero() {
        var counter = TapCounter()
        for _ in 0..<3 {
            counter.increment()
        }

        counter.reset()

        XCTAssertEqual(counter.count, 0)
    }

    @MainActor
    func testModelTapAndReset() {
        let model = TapCounterModel(history: InMemoryTapHistoryStore())
        XCTAssertEqual(model.count, 0)

        for _ in 0..<3 {
            model.tap()
        }
        XCTAssertEqual(model.count, 3)

        model.reset()
        XCTAssertEqual(model.count, 0)
    }

    @MainActor
    func testModelUsesInjectedCounter() {
        let model = TapCounterModel(counter: StubCounter(), history: InMemoryTapHistoryStore())
        XCTAssertEqual(model.count, 40)

        model.tap()
        XCTAssertEqual(model.count, 50)

        model.reset()
        XCTAssertEqual(model.count, 0)
    }
}

private struct StubCounter: TapCounting {
    var count = 40

    mutating func increment() {
        count += 10
    }

    mutating func reset() {
        count = 0
    }
}
