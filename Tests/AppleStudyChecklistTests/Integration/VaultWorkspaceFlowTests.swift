import XCTest
@testable import AppleStudyChecklist

@MainActor
final class VaultWorkspaceFlowTests: XCTestCase {
    func testMissingBundledVaultRequiresSetup() throws {
        let fixture = try ProgressFixture()
        let missingURL = fixture.rootURL.appendingPathComponent("missing-vault", isDirectory: true)

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: missingURL,
            loadWorkspaceOnInit: true
        )

        XCTAssertEqual(store.vaultState, .setupRequired)
        XCTAssertTrue(store.vaultFiles.isEmpty)
        XCTAssertFalse(store.isVaultEditable)
        XCTAssertEqual(store.sourceDescription, "Nenhum vault configurado")
    }

    func testBundledVaultWithoutWeeksSurfacesEmptyState() throws {
        let fixture = try ProgressFixture()
        let vault = try EmptyVaultFixture()

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true
        )

        XCTAssertEqual(store.vaultState, .empty)
        XCTAssertTrue(store.program.weeks.isEmpty)
        XCTAssertEqual(store.vaultFiles.count, 1)
    }

    // MARK: - New vault flow tests

    func testCreateEditableVaultFromBundle() throws {
        let fixture = try ProgressFixture()
        let bundledVault = try VaultFixture()
        let editableVaultURL = fixture.rootURL.appendingPathComponent("editable-vault", isDirectory: true)

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: bundledVault.rootURL,
            editableVaultURL: editableVaultURL,
            loadWorkspaceOnInit: true
        )

        // Precondition: starts as bundled (not editable)
        XCTAssertFalse(store.isVaultEditable)

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: editableVaultURL.path) {
            try fileManager.removeItem(at: editableVaultURL)
        }

        store.createEditableVaultFromBundle()

        // The local copy must exist on disk
        XCTAssertTrue(
            fileManager.fileExists(atPath: editableVaultURL.path),
            "Expected editable vault to be created at \(editableVaultURL.path)"
        )

        // The store must reflect the new editable mode
        XCTAssertTrue(store.isVaultEditable)
        XCTAssertEqual(store.vaultState, .ready)

        // Cleanup: remove the copy created by this test
        try? fileManager.removeItem(at: editableVaultURL)
    }

    func testSaveFileInEditableVault() throws {
        let fixture = try ProgressFixture()
        let bundledVault = try VaultFixture()
        let editableVaultURL = fixture.rootURL.appendingPathComponent("editable-vault", isDirectory: true)

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: bundledVault.rootURL,
            editableVaultURL: editableVaultURL,
            loadWorkspaceOnInit: true
        )

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: editableVaultURL.path) {
            try fileManager.removeItem(at: editableVaultURL)
        }

        // Promote the vault to an editable local copy
        store.createEditableVaultFromBundle()
        XCTAssertTrue(store.isVaultEditable, "Precondition: vault must be editable before save test")

        // Identify the first week file available in the vault
        guard let weekFile = store.vaultFiles.first(where: { $0.relativePath.hasPrefix("Weeks/") }) else {
            XCTFail("Expected at least one week file in the editable vault")
            try? fileManager.removeItem(at: editableVaultURL)
            return
        }

        // Open the file and replace its content
        store.openSelectedFile(relativePath: weekFile.relativePath)
        XCTAssertNotNil(store.selectedFile)

        let newContent = "# Modified by test\n\nThis content was written by testSaveFileInEditableVault."
        store.selectedFileContent = newContent

        // Persist the change
        store.saveSelectedFile()
        XCTAssertNil(store.lastErrorMessage, "Save must not produce an error")

        // Verify the file on disk reflects the new content
        let diskContent = try String(contentsOf: weekFile.url, encoding: .utf8)
        XCTAssertEqual(diskContent, newContent)

        // Cleanup
        try? fileManager.removeItem(at: editableVaultURL)
    }

    func testExternalFolderVaultLoadsCorrectly() throws {
        let fixture = try ProgressFixture()
        let externalVault = try VaultFixture()

        // Store starts with a missing bundled vault so there is no default workspace
        let missingURL = fixture.rootURL.appendingPathComponent("missing-vault", isDirectory: true)
        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: missingURL,
            loadWorkspaceOnInit: true
        )

        XCTAssertEqual(store.vaultState, .setupRequired, "Precondition: no vault configured yet")

        // Simulate the user selecting an external folder (direct URL load, no sandbox bookmark needed)
        store.loadExternalVault(at: externalVault.rootURL)

        XCTAssertNil(store.lastErrorMessage, "Loading an external folder must not produce an error")
        XCTAssertEqual(store.vaultState, .ready)
        XCTAssertFalse(store.program.weeks.isEmpty, "Workspace must expose weeks from the external vault")
    }
}
