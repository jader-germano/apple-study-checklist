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
}
