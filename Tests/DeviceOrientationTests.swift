import UIKit
import XCTest
@testable import HackathonApp

final class DeviceOrientationTests: XCTestCase {
    @MainActor
    func testPortraitLandscapeClassification() {
        let cases: [(DeviceOrientationKind, Bool, Bool)] = [
            (.portrait, true, false),
            (.portraitUpsideDown, true, false),
            (.landscapeLeft, false, true),
            (.landscapeRight, false, true),
            (.faceUp, false, false),
            (.faceDown, false, false),
            (.unknown, false, false)
        ]

        XCTAssertEqual(cases.count, DeviceOrientationKind.allCases.count)
        for (kind, isPortrait, isLandscape) in cases {
            XCTAssertEqual(kind.isPortrait, isPortrait, kind.rawValue)
            XCTAssertEqual(kind.isLandscape, isLandscape, kind.rawValue)
            XCTAssertFalse(kind.displayName.isEmpty, kind.rawValue)
            XCTAssertFalse(kind.systemImageName.isEmpty, kind.rawValue)
        }
    }

    @MainActor
    func testSystemOrientationMapping() {
        let cases: [(UIDeviceOrientation, DeviceOrientationKind)] = [
            (.portrait, .portrait), (.portraitUpsideDown, .portraitUpsideDown),
            (.landscapeLeft, .landscapeLeft), (.landscapeRight, .landscapeRight),
            (.faceUp, .faceUp), (.faceDown, .faceDown), (.unknown, .unknown)
        ]
        for (systemOrientation, expected) in cases {
            XCTAssertEqual(SystemOrientationProvider.kind(for: systemOrientation), expected)
        }
    }

    @MainActor
    func testModelUpdatesWhenMockOrientationChanges() {
        let mock = MockOrientationProvider()
        let model = DeviceOrientationModel(systemProvider: mock)
        model.start()
        defer { model.stop() }

        for orientation in DeviceOrientationKind.allCases {
            mock.send(orientation)
            XCTAssertEqual(model.orientation, orientation)
        }
    }

    @MainActor
    func testStartReflectsCurrentOrientation() {
        let mock = MockOrientationProvider(orientation: .portrait)
        let model = DeviceOrientationModel(systemProvider: mock)
        mock.send(.landscapeRight)

        model.start()
        defer { model.stop() }

        XCTAssertEqual(model.orientation, .landscapeRight)
        XCTAssertTrue(mock.isRunning)
    }

    @MainActor
    func testUnknownAndFaceUpHandling() {
        let mock = MockOrientationProvider(orientation: .unknown)
        let model = DeviceOrientationModel(systemProvider: mock)
        model.start()
        defer { model.stop() }

        XCTAssertEqual(model.orientation, .unknown)
        XCTAssertEqual(model.orientation.displayName, "不明")
        XCTAssertEqual(model.orientation.systemImageName, "questionmark.circle")
        XCTAssertFalse(model.orientation.isPortrait)
        XCTAssertFalse(model.orientation.isLandscape)

        mock.send(.faceUp)

        XCTAssertEqual(model.orientation, .faceUp)
        XCTAssertEqual(model.orientation.displayName, "平置き（画面が上）")
        XCTAssertEqual(model.orientation.systemImageName, "rectangle.portrait")
        XCTAssertFalse(model.orientation.isPortrait)
        XCTAssertFalse(model.orientation.isLandscape)
    }

    @MainActor
    func testNoUpdatesAfterStop() {
        let mock = MockOrientationProvider(orientation: .portrait)
        let model = DeviceOrientationModel(systemProvider: mock)
        model.start()
        model.stop()

        mock.send(.landscapeLeft)

        XCTAssertEqual(model.orientation, .portrait)
        XCTAssertEqual(mock.currentOrientation, .landscapeLeft)
        XCTAssertFalse(mock.isRunning)
        XCTAssertNil(mock.onChange)
        XCTAssertEqual(mock.stopCount, 1)
    }

    @MainActor
    func testRestartResumesUpdates() {
        let mock = MockOrientationProvider()
        let model = DeviceOrientationModel(systemProvider: mock)
        model.start()
        model.stop()
        mock.send(.faceDown)

        model.start()
        defer { model.stop() }

        XCTAssertEqual(model.orientation, .faceDown)
        mock.send(.landscapeRight)
        XCTAssertEqual(model.orientation, .landscapeRight)
        XCTAssertTrue(mock.isRunning)
        XCTAssertEqual(mock.startCount, 2)
    }

    @MainActor
    func testStartAndStopAreIdempotent() {
        let mock = MockOrientationProvider()
        let model = DeviceOrientationModel(systemProvider: mock)

        model.start()
        model.start()
        XCTAssertEqual(mock.startCount, 1)

        model.stop()
        model.stop()
        XCTAssertEqual(mock.stopCount, 1)
    }

    @MainActor
    func testSelectMockSwitchesProvider() {
        let system = MockOrientationProvider(orientation: .portrait)
        let mock = MockOrientationProvider(orientation: .faceUp)
        let model = DeviceOrientationModel(systemProvider: system, mockProvider: mock)
        model.start()
        defer { model.stop() }

        model.setUsingMock(true)
        XCTAssertTrue(model.isUsingMock)
        XCTAssertEqual(model.orientation, .faceUp)
        XCTAssertFalse(system.isRunning)
        XCTAssertNil(system.onChange)
        XCTAssertTrue(mock.isRunning)

        model.selectMock(.landscapeLeft)
        XCTAssertEqual(model.orientation, .landscapeLeft)
        XCTAssertEqual(mock.startCount, 1)

        system.send(.portraitUpsideDown)
        XCTAssertEqual(model.orientation, .landscapeLeft)

        model.setUsingMock(false)
        XCTAssertFalse(model.isUsingMock)
        XCTAssertEqual(model.orientation, .portraitUpsideDown)
        XCTAssertFalse(mock.isRunning)
        XCTAssertNil(mock.onChange)
        XCTAssertTrue(system.isRunning)

        mock.send(.unknown)
        XCTAssertEqual(model.orientation, .portraitUpsideDown)
        system.send(.landscapeRight)
        XCTAssertEqual(model.orientation, .landscapeRight)
    }

    @MainActor
    func testSelectingMockWhileStoppedDoesNotStartUpdates() {
        let system = MockOrientationProvider()
        let mock = MockOrientationProvider()
        let model = DeviceOrientationModel(systemProvider: system, mockProvider: mock)
        model.start()
        model.stop()

        model.selectMock(.faceDown)

        XCTAssertTrue(model.isUsingMock)
        XCTAssertEqual(model.orientation, .portrait)
        XCTAssertFalse(system.isRunning)
        XCTAssertFalse(mock.isRunning)

        model.start()
        XCTAssertEqual(model.orientation, .faceDown)
        model.stop()
        XCTAssertFalse(mock.isRunning)
    }

    @MainActor
    func testDeviceOrientationIsRegistered() throws {
        let entry = try XCTUnwrap(CapabilityRegistry.entries.first {
            $0.id == CapabilityID.deviceOrientation
        })

        XCTAssertTrue(CapabilityID.isValid(entry.id))
        XCTAssertEqual(entry.title, "Device Orientation")
        XCTAssertFalse(entry.deviceChecks.isEmpty)
        _ = entry.makeView()
    }
}
