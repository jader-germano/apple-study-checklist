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
