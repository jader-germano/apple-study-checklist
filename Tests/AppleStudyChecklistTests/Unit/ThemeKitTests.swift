import XCTest
@testable import AppleStudyChecklist

final class ThemeKitTests: XCTestCase {
    func testProgressPhaseReturnsLockedWhenRatioIsZeroOrNegative() {
        XCTAssertEqual(Theme.progressPhase(for: 0), .locked)
        XCTAssertEqual(Theme.progressPhase(for: -0.25), .locked)
    }

    func testProgressPhaseReturnsActiveForPartialProgress() {
        XCTAssertEqual(Theme.progressPhase(for: 0.01), .active)
        XCTAssertEqual(Theme.progressPhase(for: 0.99), .active)
    }

    func testProgressPhaseReturnsCompleteWhenRatioReachesOne() {
        XCTAssertEqual(Theme.progressPhase(for: 1.0), .complete)
        XCTAssertEqual(Theme.progressPhase(for: 1.5), .complete)
    }

    func testProgressPhaseTreatsNonFiniteValuesAsLocked() {
        XCTAssertEqual(Theme.progressPhase(for: .infinity), .locked)
        XCTAssertEqual(Theme.progressPhase(for: .nan), .locked)
    }
}
