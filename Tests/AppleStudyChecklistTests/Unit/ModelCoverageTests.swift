import XCTest
@testable import AppleStudyChecklist

final class ModelCoverageTests: XCTestCase {
    func testVaultFileEntryDisplayNameUsesLastPathComponent() {
        let url = URL(fileURLWithPath: "/tmp/notes/week-01.md")
        let entry = VaultFileEntry(id: "week-01.md", relativePath: "Weeks/week-01.md", url: url)

        XCTAssertEqual(entry.displayName, "week-01.md")
    }

    func testAppearanceModeIdentifiersDisplayNamesAndColorSchemes() {
        XCTAssertEqual(AppearanceMode.automatic.id, AppearanceMode.automatic.rawValue)
        XCTAssertEqual(AppearanceMode.automatic.displayName(for: .english), "Automatic")
        XCTAssertEqual(AppearanceMode.automatic.displayName(for: .portuguese), "Automático")
        XCTAssertNil(AppearanceMode.automatic.colorScheme)

        XCTAssertEqual(AppearanceMode.light.displayName(for: .english), "Light")
        XCTAssertEqual(AppearanceMode.light.displayName(for: .portuguese), "Claro")
        XCTAssertEqual(AppearanceMode.light.colorScheme, .light)

        XCTAssertEqual(AppearanceMode.dark.displayName(for: .english), "Dark")
        XCTAssertEqual(AppearanceMode.dark.displayName(for: .portuguese), "Escuro")
        XCTAssertEqual(AppearanceMode.dark.colorScheme, .dark)
    }

    func testAppLanguageIdentifiersAndDisplayNames() {
        XCTAssertEqual(AppLanguage.portuguese.id, "pt-BR")
        XCTAssertEqual(AppLanguage.portuguese.displayName, "Português (Brasil)")
        XCTAssertEqual(AppLanguage.english.id, "en")
        XCTAssertEqual(AppLanguage.english.displayName, "English")
    }

    func testVaultWorkspaceStateShowsSetupActionsOutsideReadyState() {
        XCTAssertFalse(VaultWorkspaceState.ready.showsSetupActions)
        XCTAssertTrue(VaultWorkspaceState.empty.showsSetupActions)
        XCTAssertTrue(VaultWorkspaceState.setupRequired.showsSetupActions)
    }
}
