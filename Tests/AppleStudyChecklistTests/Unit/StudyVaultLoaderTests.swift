import XCTest
@testable import AppleStudyChecklist

final class StudyVaultLoaderTests: XCTestCase {
    func testLoadsWorkspaceFromMarkdownVault() throws {
        let fixture = try VaultFixture()

        let payload = try StudyVaultLoader.load(from: fixture.rootURL)

        XCTAssertEqual(payload.workspace.program.title, "Custom Track")
        XCTAssertEqual(payload.workspace.program.weeks.count, 2)
        XCTAssertTrue(payload.workspace.program.weeks.first?.studyText.contains("Week 1 body") == true)
        XCTAssertEqual(payload.workspace.labels.planTabTitle, "Roadmap")
        XCTAssertEqual(payload.files.count, 3)
    }
}
