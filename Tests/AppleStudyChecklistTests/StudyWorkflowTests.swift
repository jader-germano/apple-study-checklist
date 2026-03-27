import Foundation
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

@MainActor
final class StudyStoreTests: XCTestCase {
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

private final class VaultFixture {
    let rootURL: URL

    init() throws {
        rootURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: rootURL.appendingPathComponent("Config", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: rootURL.appendingPathComponent("Weeks", isDirectory: true),
            withIntermediateDirectories: true
        )

        try """
---
title: Custom Track
start_date: 2026-04-01
schedule_label: Bloco sugerido: 07:00-08:00
day_title_prefix: Step
phase_labels: Explore|Practice|Review
label_plan_tab: Roadmap
label_vault_tab: Notes
---
Config body
""".write(
            to: rootURL.appendingPathComponent("Config", isDirectory: true).appendingPathComponent("app-config.md"),
            atomically: true,
            encoding: .utf8
        )

        try """
---
week_number: 1
title: SwiftUI Foundations
objective: Build the shared UI model
deliverable: A validated shell
glossary: SwiftUI|Scene
references: SwiftUI|https://developer.apple.com/swiftui/||Scene|https://developer.apple.com/documentation/swiftui/scene
---
Week 1 body
""".write(
            to: rootURL.appendingPathComponent("Weeks", isDirectory: true).appendingPathComponent("week-01.md"),
            atomically: true,
            encoding: .utf8
        )

        try """
---
week_number: 2
title: Vault Mapping
objective: Load markdown content
deliverable: A local content flow
glossary: Markdown|Vault
references: Foundation|https://developer.apple.com/documentation/foundation
---
Week 2 body
""".write(
            to: rootURL.appendingPathComponent("Weeks", isDirectory: true).appendingPathComponent("week-02.md"),
            atomically: true,
            encoding: .utf8
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: rootURL)
    }
}

private final class EmptyVaultFixture {
    let rootURL: URL

    init() throws {
        rootURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: rootURL.appendingPathComponent("Config", isDirectory: true),
            withIntermediateDirectories: true
        )

        try """
---
title: Empty Track
start_date: 2026-04-01
schedule_label: Bloco sugerido: 07:00-08:00
---
Config body
""".write(
            to: rootURL.appendingPathComponent("Config", isDirectory: true).appendingPathComponent("app-config.md"),
            atomically: true,
            encoding: .utf8
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: rootURL)
    }
}

private final class ProgressFixture {
    let rootURL: URL
    let saveURL: URL
    let defaults: UserDefaults
    private let suiteName: String

    init() throws {
        rootURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        saveURL = rootURL.appendingPathComponent("progress.json")
        suiteName = "AppleStudyChecklistTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName) ?? .standard
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: rootURL)
    }
}
