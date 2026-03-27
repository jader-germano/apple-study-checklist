import Foundation

final class VaultFixture {
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
title_en: Custom Track EN
start_date: 2026-04-01
schedule_label: Bloco sugerido: 07:00-08:00
schedule_label_en: Suggested block: 07:00-08:00
day_title_prefix: Step
day_title_prefix_en: Day
phase_labels: Explore|Practice|Review
phase_labels_en: Explore|Practice|Review
label_plan_tab: Roadmap
label_vault_tab: Notes
label_language_en: Language
task_read_title_en: Read the main topic block
task_read_note_template_en: Focus on {title_lowercased} and write down the weak terms.
task_practice_title_en: Run a practical activity
task_practice_note_template_en: Connect the reading to practice using the objective: {objective}
task_record_title_en: Record an objective output
task_record_note_template_en: Update your notes with a verifiable result: {deliverable}
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
title_en: SwiftUI Foundations EN
objective: Build the shared UI model
objective_en: Build the shared UI model in English
deliverable: A validated shell
deliverable_en: A validated shell in English
study_text_en: Week 1 body in English
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

final class EmptyVaultFixture {
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

final class ProgressFixture {
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
