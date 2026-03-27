import XCTest
@testable import AppleStudyChecklist

@MainActor
final class StudyStorePersistenceTests: XCTestCase {
    func testCompletedTasksPersistAcrossReloads() throws {
        let fixture = try ProgressFixture()
        let taskID = StudyCatalog.program.weeks[0].days[0].tasks[0].id

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )
        store.binding(for: taskID).wrappedValue = true

        let reloadedStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        XCTAssertTrue(reloadedStore.isCompleted(taskID))
    }

    func testResetClearsOnlySelectedWeek() throws {
        let fixture = try ProgressFixture()
        let firstWeek = StudyCatalog.program.weeks[0]
        let secondWeek = StudyCatalog.program.weeks[1]
        let firstWeekTaskID = firstWeek.days[0].tasks[0].id
        let secondWeekTaskID = secondWeek.days[0].tasks[0].id

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )
        store.binding(for: firstWeekTaskID).wrappedValue = true
        store.binding(for: secondWeekTaskID).wrappedValue = true

        store.reset(firstWeek)

        XCTAssertFalse(store.isCompleted(firstWeekTaskID))
        XCTAssertTrue(store.isCompleted(secondWeekTaskID))
    }

    func testRestoresAppearancePreference() throws {
        let fixture = try ProgressFixture()
        fixture.defaults.set(AppearanceMode.dark.rawValue, forKey: "study-appearance")

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        XCTAssertEqual(store.appearance, .dark)
    }

    func testRestoresLanguagePreference() throws {
        let fixture = try ProgressFixture()
        fixture.defaults.set(AppLanguage.english.rawValue, forKey: "study-language")

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        XCTAssertEqual(store.language, .english)
        XCTAssertEqual(store.labels.languageLabel, "Language")
        XCTAssertEqual(store.labels.planTabTitle, "Plan")
    }

    func testChangingLanguageReloadsWorkspaceLabels() throws {
        let fixture = try ProgressFixture()
        let vault = try VaultFixture()

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true
        )

        XCTAssertEqual(store.labels.languageLabel, "Idioma")

        store.updateLanguage(.english)

        XCTAssertEqual(store.language, .english)
        XCTAssertEqual(store.labels.languageLabel, "Language")
        XCTAssertEqual(store.sourceDescription, "Bundled vault")
    }
}
