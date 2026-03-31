import Foundation
import XCTest
@testable import AppleStudyChecklist

final class StudyVaultLoaderCoverageTests: XCTestCase {
    func testResolveBundledVaultURLSupportsMissingNestedAndFlattenedLayouts() throws {
        XCTAssertNil(StudyVaultLoader.resolveBundledVaultURL(resourceURL: nil))

        let nestedFixture = try TemporaryDirectoryFixture()
        try write(
            """
            ---
            title: Nested
            ---
            """,
            to: nestedFixture.rootURL
                .appendingPathComponent("Vault", isDirectory: true)
                .appendingPathComponent("Config", isDirectory: true)
                .appendingPathComponent("app-config.md")
        )

        XCTAssertEqual(
            StudyVaultLoader.resolveBundledVaultURL(resourceURL: nestedFixture.rootURL),
            nestedFixture.rootURL.appendingPathComponent("Vault", isDirectory: true)
        )

        let flatFixture = try TemporaryDirectoryFixture()
        try write(
            """
            ---
            title: Flat
            ---
            """,
            to: flatFixture.rootURL.appendingPathComponent("app-config.md")
        )

        XCTAssertEqual(
            StudyVaultLoader.resolveBundledVaultURL(resourceURL: flatFixture.rootURL),
            flatFixture.rootURL
        )

        let emptyFixture = try TemporaryDirectoryFixture()
        XCTAssertNil(StudyVaultLoader.resolveBundledVaultURL(resourceURL: emptyFixture.rootURL))
    }

    func testLoadUsesDefaultsWhenConfigurationHasNoFrontMatter() throws {
        let fixture = try TemporaryDirectoryFixture()
        try write("Configuration body only", to: fixture.rootURL.appendingPathComponent("app-config.md"))
        try write(
            """
            ---
            week_number: 1
            title: Week From Defaults
            objective: Exercise default config
            deliverable: Validate fallback
            ---
            Body
            """,
            to: fixture.rootURL.appendingPathComponent("week-01.md")
        )

        let payload = try StudyVaultLoader.load(from: fixture.rootURL)

        XCTAssertEqual(payload.workspace.program.title, "Apple OS Developer Track")
        XCTAssertEqual(payload.workspace.program.scheduleLabel, "Bloco diário sugerido: 08:00-09:30")
        XCTAssertEqual(payload.workspace.program.weeks.count, 1)
        XCTAssertEqual(payload.workspace.program.weeks[0].days.count, 0)
    }

    func testLoadTreatsMalformedWeekFrontMatterAsPlainMarkdownBody() throws {
        let fixture = try TemporaryDirectoryFixture()
        try write(
            """
            ---
            title: Config
            phase_labels: Explore
            ---
            Config body
            """,
            to: fixture.rootURL
                .appendingPathComponent("Config", isDirectory: true)
                .appendingPathComponent("app-config.md")
        )
        try write(
            """
            ---
            title: Broken Week
            objective: Missing footer
            """,
            to: fixture.rootURL
                .appendingPathComponent("Weeks", isDirectory: true)
                .appendingPathComponent("week-01.md")
        )

        let payload = try StudyVaultLoader.load(from: fixture.rootURL)
        let week = try XCTUnwrap(payload.workspace.program.weeks.first)

        XCTAssertEqual(week.title, "Semana 1")
        XCTAssertTrue(week.studyText.hasPrefix("---"))
    }

    func testLoadContextualizesMissingObjectiveDeliverableAndTaskNotes() throws {
        let fixture = try TemporaryDirectoryFixture()
        try write(
            """
            ---
            title: Coverage Config
            phase_labels: Explore|Practice
            task_read_note_template:
            task_practice_note_template: Do the work
            task_record_note_template: Close {phase_lowercased} with notes
            ---
            Config body
            """,
            to: fixture.rootURL
                .appendingPathComponent("Config", isDirectory: true)
                .appendingPathComponent("app-config.md")
        )
        try write(
            """
            ---
            week_number: 1
            title: Coverage Week
            objective:
            deliverable:
            ---
            Week body
            """,
            to: fixture.rootURL
                .appendingPathComponent("Weeks", isDirectory: true)
                .appendingPathComponent("week-01.md")
        )

        let payload = try StudyVaultLoader.load(from: fixture.rootURL)
        let firstDay = try XCTUnwrap(payload.workspace.program.weeks.first?.days.first)

        XCTAssertEqual(firstDay.focus, "Explore")
        XCTAssertEqual(firstDay.output, "Explore")
        XCTAssertEqual(firstDay.tasks[0].note, "")
        XCTAssertEqual(firstDay.tasks[1].note, "Explore: Do the work")
        XCTAssertEqual(firstDay.tasks[2].note, "Close explore with notes")
    }

    func testLoadFailsWhenRootURLIsNotADirectory() throws {
        let fixture = try TemporaryDirectoryFixture()
        let fileURL = fixture.rootURL.appendingPathComponent("single.md")
        try write("# not a vault", to: fileURL)

        XCTAssertThrowsError(try StudyVaultLoader.load(from: fileURL))
        XCTAssertEqual(try StudyVaultLoader.enumerateMarkdownFiles(in: fileURL), [])
    }

    func testRelativePathFallsBackToFilenameForExternalTarget() throws {
        let baseFixture = try TemporaryDirectoryFixture()
        let externalFixture = try TemporaryDirectoryFixture()
        let externalFile = externalFixture.rootURL.appendingPathComponent("outside.md")
        try write("# outside", to: externalFile)

        let relativePath = StudyVaultLoader.relativePath(from: baseFixture.rootURL, to: externalFile)

        XCTAssertEqual(relativePath, "outside.md")
    }

    private func write(_ text: String, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try text.write(to: url, atomically: true, encoding: .utf8)
    }
}
