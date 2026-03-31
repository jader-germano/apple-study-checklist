import Foundation
import XCTest
@testable import AppleStudyChecklist

@MainActor
final class StudyStoreCoverageTests: XCTestCase {
    func testMakeSupportURLsUseProvidedBaseFolder() throws {
        let fixture = try TemporaryDirectoryFixture()
        let defaultSaveURL = StudyStore.makeSaveURL()

        let saveURL = StudyStore.makeSaveURL(baseURL: fixture.rootURL)
        let editableVaultURL = StudyStore.makeEditableVaultURL(baseURL: fixture.rootURL)

        XCTAssertEqual(defaultSaveURL.lastPathComponent, "progress.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: saveURL.deletingLastPathComponent().path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: editableVaultURL.deletingLastPathComponent().path))
        XCTAssertEqual(saveURL.lastPathComponent, "progress.json")
        XCTAssertEqual(editableVaultURL.lastPathComponent, "Vault")
    }

    func testCompletedCountProgressAndAppearancePersistence() throws {
        let fixture = try ProgressFixture()
        let week = StudyCatalog.program.weeks[0]
        let firstDay = week.days[0]
        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        XCTAssertEqual(store.completedCount(for: firstDay), 0)
        XCTAssertEqual(store.progress(for: week), 0)

        let firstTaskID = firstDay.tasks[0].id
        let secondTaskID = firstDay.tasks[1].id
        store.binding(for: firstTaskID).wrappedValue = true
        store.binding(for: secondTaskID).wrappedValue = true

        XCTAssertEqual(store.completedCount(for: firstDay), 2)
        XCTAssertGreaterThan(store.progress(for: week), 0)

        store.updateAppearance(.light)

        XCTAssertEqual(store.appearance, .light)
        XCTAssertEqual(fixture.defaults.string(forKey: "study-appearance"), AppearanceMode.light.rawValue)
    }

    func testOpenSelectedFileCoversNilUnknownSuccessAndFailurePaths() throws {
        let fixture = try ProgressFixture()
        let vault = try VaultFixture()
        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true
        )

        store.openSelectedFile(relativePath: nil)
        XCTAssertNil(store.selectedFile)
        XCTAssertEqual(store.selectedFileContent, "")

        store.openSelectedFile(relativePath: "missing.md")
        XCTAssertNil(store.selectedFile)
        XCTAssertEqual(store.selectedFileContent, "")

        let relativePath = try XCTUnwrap(store.vaultFiles.first?.relativePath)
        store.openSelectedFile(relativePath: relativePath)
        XCTAssertEqual(store.selectedFile?.relativePath, relativePath)
        XCTAssertFalse(store.selectedFileContent.isEmpty)

        let selectedURL = try XCTUnwrap(store.selectedFile?.url)
        try FileManager.default.removeItem(at: selectedURL)
        store.lastErrorMessage = nil
        store.openSelectedFile(relativePath: relativePath)

        XCTAssertEqual(store.selectedFileContent, "")
        XCTAssertNotNil(store.lastErrorMessage)
    }

    func testSaveSelectedFileCoversReadOnlySuccessAndFailurePaths() throws {
        let fixture = try ProgressFixture()
        let vault = try VaultFixture()

        let readOnlyStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true
        )
        let bundledFilePath = try XCTUnwrap(readOnlyStore.vaultFiles.first?.relativePath)
        readOnlyStore.openSelectedFile(relativePath: bundledFilePath)
        readOnlyStore.selectedFileContent = "blocked"
        readOnlyStore.saveSelectedFile()
        XCTAssertEqual(readOnlyStore.lastErrorMessage, readOnlyStore.labels.readOnlyNotice)

        let editableVaultURL = fixture.rootURL.appendingPathComponent("EditableVault", isDirectory: true)
        let editableStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: false,
            editableVaultURL: editableVaultURL
        )
        editableStore.createEditableVaultFromBundle()

        let editableFilePath = try XCTUnwrap(editableStore.vaultFiles.first?.relativePath)
        editableStore.openSelectedFile(relativePath: editableFilePath)
        editableStore.selectedFileContent = "# Updated"
        editableStore.lastErrorMessage = nil
        editableStore.saveSelectedFile()

        let savedURL = try XCTUnwrap(editableStore.selectedFile?.url)
        XCTAssertEqual(try String(contentsOf: savedURL, encoding: .utf8), "# Updated")
        XCTAssertNil(editableStore.lastErrorMessage)

        try FileManager.default.removeItem(at: editableVaultURL)
        editableStore.selectedFileContent = "# Fails"
        editableStore.saveSelectedFile()

        XCTAssertNotNil(editableStore.lastErrorMessage)
    }

    func testCreateEditableVaultHandlesMissingBundledVaultAndCopyFailure() throws {
        let fixture = try ProgressFixture()

        let englishStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )
        englishStore.updateLanguage(.english)
        englishStore.createEditableVaultFromBundle()

        XCTAssertEqual(englishStore.vaultState, .setupRequired)
        XCTAssertEqual(englishStore.sourceDescription, "No vault configured")
        XCTAssertEqual(englishStore.lastErrorMessage, "Could not locate the bundled vault.")

        let vault = try VaultFixture()
        let invalidTarget = fixture.rootURL
            .appendingPathComponent("missing-parent", isDirectory: true)
            .appendingPathComponent("Vault", isDirectory: true)
        let failingStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: false,
            editableVaultURL: invalidTarget
        )

        failingStore.createEditableVaultFromBundle()

        XCTAssertNotNil(failingStore.lastErrorMessage)
    }

    func testChooseVaultFolderAndImportErrorPaths() throws {
        let fixture = try ProgressFixture()
        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        store.chooseVaultFolder()
        XCTAssertTrue(store.isImportingVault)

        store.handleVaultImport(.success([]))
        XCTAssertFalse(store.isImportingVault)
        XCTAssertEqual(store.lastErrorMessage, "Nenhuma pasta foi selecionada.")

        store.chooseVaultFolder()
        store.handleVaultImport(.failure(NSError(domain: "StudyStoreCoverage", code: 42, userInfo: [NSLocalizedDescriptionKey: "boom"])))
        XCTAssertFalse(store.isImportingVault)
        XCTAssertEqual(store.lastErrorMessage, "boom")
    }

    func testHandleVaultImportSuccessResetAndBookmarkFailure() throws {
        let fixture = try ProgressFixture()
        let vault = try VaultFixture()
        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true
        )

        XCTAssertEqual(store.sourceDescription, "Vault integrado ao app")

        store.handleVaultImport(.success([vault.rootURL]))
        XCTAssertEqual(store.sourceDescription, "Vault externo conectado")
        XCTAssertTrue(store.isVaultEditable)
        XCTAssertNotNil(fixture.defaults.data(forKey: "vault-external-bookmark"))

        store.resetToBundledVault()
        XCTAssertEqual(store.sourceDescription, "Vault integrado ao app")
        XCTAssertNil(fixture.defaults.data(forKey: "vault-external-bookmark"))

        let failingStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: false,
            makeBookmarkData: { _ in
                throw NSError(domain: "StudyStoreCoverage", code: 13, userInfo: [NSLocalizedDescriptionKey: "bookmark failed"])
            }
        )
        failingStore.handleVaultImport(.success([vault.rootURL]))

        XCTAssertEqual(failingStore.lastErrorMessage, "bookmark failed")

        let englishEditableVaultURL = fixture.rootURL.appendingPathComponent("EnglishVault", isDirectory: true)
        let englishStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: vault.rootURL,
            loadWorkspaceOnInit: true,
            editableVaultURL: englishEditableVaultURL
        )
        englishStore.updateLanguage(.english)
        englishStore.createEditableVaultFromBundle()
        XCTAssertEqual(englishStore.sourceDescription, "Local vault in Application Support")

        englishStore.handleVaultImport(.success([vault.rootURL]))
        XCTAssertEqual(englishStore.sourceDescription, "Connected external vault")
    }

    func testReloadWorkspaceHandlesMissingExternalBookmarkAndStaleRefresh() throws {
        let fixture = try ProgressFixture()
        let vault = try VaultFixture()

        fixture.defaults.set("external", forKey: "vault-mode")
        let missingExternalStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )
        missingExternalStore.reloadWorkspace()
        XCTAssertEqual(missingExternalStore.vaultState, .setupRequired)
        XCTAssertEqual(missingExternalStore.sourceDescription, "Nenhum vault configurado")
        XCTAssertNotNil(missingExternalStore.lastErrorMessage)

        let refreshedData = Data("refreshed".utf8)
        fixture.defaults.set("external", forKey: "vault-mode")
        fixture.defaults.set(Data("stale".utf8), forKey: "vault-external-bookmark")
        let staleStore = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false,
            makeBookmarkData: { _ in refreshedData },
            resolveBookmarkData: { _, isStale in
                isStale = true
                return vault.rootURL
            }
        )

        staleStore.reloadWorkspace()

        XCTAssertEqual(fixture.defaults.data(forKey: "vault-external-bookmark"), refreshedData)
        XCTAssertEqual(staleStore.sourceDescription, "Vault externo conectado")
        XCTAssertEqual(staleStore.vaultState, .ready)
    }
}
