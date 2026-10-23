import XCTest
@testable import HackathonApp

final class HapticsCapabilityTests: XCTestCase {
    @MainActor
    func testEachImpactIsForwarded() {
        let styles: [HapticImpactStyle] = [.light, .medium, .heavy, .soft, .rigid]
        for style in styles {
            let player = MockHapticsPlayer()
            let model = HapticsModel(player: player)

            model.impact(style)

            XCTAssertEqual(player.calls, [.impact(style)])
            XCTAssertEqual(model.lastAction, "Impact: \(style.rawValue)")
        }
    }

    @MainActor
    func testEachNotificationIsForwarded() {
        let types: [HapticNotificationType] = [.success, .warning, .error]
        for type in types {
            let player = MockHapticsPlayer()
            let model = HapticsModel(player: player)

            model.notify(type)

            XCTAssertEqual(player.calls, [.notification(type)])
            XCTAssertEqual(model.lastAction, "Notification: \(type.rawValue)")
        }
    }

    @MainActor
    func testSelectionIsForwarded() {
        let player = MockHapticsPlayer()
        let model = HapticsModel(player: player)

        model.select()

        XCTAssertEqual(player.calls, [.selection])
        XCTAssertEqual(model.lastAction, "Selection")
    }

    @MainActor
    func testSupportedCustomPatternIsForwarded() {
        let player = MockHapticsPlayer(supportsCustomHaptics: true)
        let model = HapticsModel(player: player)
        XCTAssertTrue(model.supportsCustomHaptics)

        model.playCustomPattern()

        XCTAssertEqual(player.calls, [.pattern(.demo)])
        XCTAssertEqual(model.lastAction, "Custom pattern")
    }

    @MainActor
    func testUnsupportedCustomPatternIsNotForwarded() {
        let player = MockHapticsPlayer()
        let model = HapticsModel(player: player)
        XCTAssertFalse(model.supportsCustomHaptics)

        model.playCustomPattern()

        XCTAssertTrue(player.calls.isEmpty)
        XCTAssertEqual(model.lastAction, "カスタムハプティクスは非対応です。")
    }

    @MainActor
    func testHapticsIsRegistered() throws {
        let entry = try XCTUnwrap(CapabilityRegistry.entries.first { $0.id == CapabilityID.haptics })

        XCTAssertTrue(CapabilityID.isValid(entry.id))
        XCTAssertEqual(entry.title, "Haptics")
        XCTAssertFalse(entry.deviceChecks.isEmpty)
        _ = entry.makeView()
    }

    #if targetEnvironment(simulator)
    @MainActor
    func testSimulatorDefaultsToMock() {
        let player = HapticsModel.defaultPlayer()
        XCTAssertTrue(player is MockHapticsPlayer)
        XCTAssertFalse(player.supportsCustomHaptics)
    }
    #endif
}
