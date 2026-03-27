import Foundation
import Testing
@testable import AppleStudyChecklist

@Suite("Study vault loader")
struct StudyVaultLoaderTests {
    @Test("loads labels, weeks, and markdown files from a local vault")
    func loadsWorkspaceFromMarkdownVault() throws {
        let fixture = try VaultFixture()

        let payload = try StudyVaultLoader.load(from: fixture.rootURL)

        #expect(payload.workspace.program.title == "Custom Track")
        #expect(payload.workspace.program.weeks.count == 2)
        #expect(payload.workspace.program.weeks.first?.studyText.contains("Week 1 body") == true)
        #expect(payload.workspace.labels.planTabTitle == "Roadmap")
        #expect(payload.files.count == 3)
    }
}

@Suite("Study store")
struct StudyStoreTests {
    @MainActor
    @Test("completed tasks persist across store reloads")
    func completedTasksPersistAcrossReloads() throws {
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

        #expect(reloadedStore.isCompleted(taskID))
    }

    @MainActor
    @Test("reset clears only the selected week")
    func resetClearsOnlySelectedWeek() throws {
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

        #expect(store.isCompleted(firstWeekTaskID) == false)
        #expect(store.isCompleted(secondWeekTaskID))
    }

    @MainActor
    @Test("appearance preference is restored from defaults")
    func restoresAppearancePreference() throws {
        let fixture = try ProgressFixture()
        fixture.defaults.set(AppearanceMode.dark.rawValue, forKey: "study-appearance")

        let store = StudyStore(
            saveURL: fixture.saveURL,
            defaults: fixture.defaults,
            bundledVaultURL: nil,
            loadWorkspaceOnInit: false
        )

        #expect(store.appearance == .dark)
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
