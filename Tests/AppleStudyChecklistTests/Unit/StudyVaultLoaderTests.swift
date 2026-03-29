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

    func testLoadsEnglishLabelsFromLocalizedVaultMetadata() throws {
        let fixture = try VaultFixture()

        let payload = try StudyVaultLoader.load(from: fixture.rootURL, language: .english)

        XCTAssertEqual(payload.workspace.labels.planTabTitle, "Roadmap")
        XCTAssertEqual(payload.workspace.labels.languageLabel, "Language")
        XCTAssertEqual(payload.workspace.program.title, "Custom Track EN")
        XCTAssertEqual(payload.workspace.program.scheduleLabel, "Suggested block: 07:00-08:00")
        XCTAssertEqual(payload.workspace.program.weeks.first?.title, "SwiftUI Foundations EN")
        XCTAssertEqual(payload.workspace.program.weeks.first?.objective, "Build the shared UI model in English")
        XCTAssertEqual(payload.workspace.program.weeks.first?.deliverable, "A validated shell in English")
        XCTAssertEqual(payload.workspace.program.weeks.first?.studyText, "Week 1 body in English")
        XCTAssertEqual(payload.workspace.program.weeks.first?.days.first?.title, "Day 1")
        XCTAssertEqual(payload.workspace.program.weeks.first?.days.first?.tasks.first?.title, "Explore: Read the main topic block")
    }

    func testLoadsBundledVaultResourcesFromModuleBundle() throws {
        guard let bundledURL = StudyVaultLoader.bundledVaultURL() else {
            return XCTFail("Expected bundled vault URL to be available")
        }

        let payload = try StudyVaultLoader.load(from: bundledURL)

        XCTAssertEqual(payload.workspace.program.weeks.count, 12)
        XCTAssertEqual(payload.workspace.program.weeks.first?.title, "Darwin, filesystem e app bundles")
        XCTAssertTrue(payload.files.contains { $0.relativePath.hasSuffix("app-config.md") })
    }

    func testBuildsPhaseSpecificDailyDetailsToAvoidRepeatedComments() throws {
        let fixture = try VaultFixture()
        let payload = try StudyVaultLoader.load(from: fixture.rootURL, language: .english)
        let week = try XCTUnwrap(payload.workspace.program.weeks.first)
        let firstDay = try XCTUnwrap(week.days.first)
        let secondDay = try XCTUnwrap(week.days.dropFirst().first)

        XCTAssertNotEqual(firstDay.focus, secondDay.focus)
        XCTAssertNotEqual(firstDay.output, secondDay.output)
        XCTAssertNotEqual(firstDay.tasks.map(\.note), secondDay.tasks.map(\.note))
        XCTAssertTrue(firstDay.tasks.allSatisfy { $0.note.localizedCaseInsensitiveContains(firstDay.phase) })
        XCTAssertTrue(secondDay.tasks.allSatisfy { $0.note.localizedCaseInsensitiveContains(secondDay.phase) })
    }

    func testBundledVaultUsesDistinctOperationalCopyAcrossDays() throws {
        guard let bundledURL = StudyVaultLoader.bundledVaultURL() else {
            return XCTFail("Expected bundled vault URL to be available")
        }

        let payload = try StudyVaultLoader.load(from: bundledURL)
        let week = try XCTUnwrap(payload.workspace.program.weeks.first)
        let firstDay = try XCTUnwrap(week.days.first)
        let secondDay = try XCTUnwrap(week.days.dropFirst().first)

        XCTAssertNotEqual(firstDay.focus, secondDay.focus)
        XCTAssertNotEqual(firstDay.output, secondDay.output)
        XCTAssertNotEqual(firstDay.tasks.map(\.note), secondDay.tasks.map(\.note))
        XCTAssertTrue(firstDay.tasks.allSatisfy { $0.note.localizedCaseInsensitiveContains(firstDay.phase) })
        XCTAssertTrue(secondDay.tasks.allSatisfy { $0.note.localizedCaseInsensitiveContains(secondDay.phase) })
    }
}
