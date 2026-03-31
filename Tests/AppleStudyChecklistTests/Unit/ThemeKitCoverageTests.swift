import SwiftUI
import XCTest
@testable import AppleStudyChecklist

final class ThemeKitCoverageTests: XCTestCase {
    func testProgressTintCanBeResolvedForEveryPhase() {
        _ = Theme.progressTint(for: -1)
        _ = Theme.progressTint(for: 0.5)
        _ = Theme.progressTint(for: 1.0)

        XCTAssertEqual(Theme.progressPhase(for: -1), .locked)
        XCTAssertEqual(Theme.progressPhase(for: 0.5), .active)
        XCTAssertEqual(Theme.progressPhase(for: 1.0), .complete)
    }

    func testThemeGradientsCanBeMaterialized() {
        let gradients = [Theme.accentGradient, Theme.userBubbleGradient, Theme.bgGradient]

        XCTAssertEqual(gradients.count, 3)
    }

    func testColorHexInitializesForSupportedAndFallbackFormats() {
        let colors = [
            Color(hex: "F0A"),
            Color(hex: "FF00AA"),
            Color(hex: "CCFF00AA"),
            Color(hex: "invalid")
        ]

        XCTAssertEqual(colors.count, 4)
    }
}
