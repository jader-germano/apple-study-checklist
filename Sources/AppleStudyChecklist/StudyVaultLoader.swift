import Foundation

enum StudyVaultLoader {
    struct Payload {
        let workspace: StudyWorkspace
        let files: [VaultFileEntry]
    }

    private struct MarkdownDocument {
        let metadata: [String: String]
        let body: String
    }

    private struct VaultConfiguration {
        let title: String
        let startDate: Date
        let scheduleLabel: String
        let labels: StudyLabels
        let dayTitlePrefix: String
        let phaseLabels: [String]
        let taskTemplates: [(title: String, noteTemplate: String)]
    }

    static func load(from vaultURL: URL) throws -> Payload {
        let files = try enumerateMarkdownFiles(in: vaultURL)
        let configEntry = try resolveConfigurationFile(in: files, vaultURL: vaultURL)
        let config = try loadConfiguration(from: configEntry.url)
        let weekFiles = resolveWeekFiles(in: files, configurationEntry: configEntry)
        let weeks = try weekFiles.map { try loadWeek(from: $0.url, configuration: config) }

        let program = StudyProgram(
            title: config.title,
            startDate: config.startDate,
            scheduleLabel: config.scheduleLabel,
            weeks: weeks.sorted { $0.weekNumber < $1.weekNumber }
        )

        return Payload(
            workspace: StudyWorkspace(program: program, labels: config.labels),
            files: files.sorted { $0.relativePath < $1.relativePath }
        )
    }

    private static func resolveConfigurationFile(in files: [VaultFileEntry], vaultURL: URL) throws -> VaultFileEntry {
        if let nested = files.first(where: { $0.relativePath == "Config/app-config.md" }) {
            return nested
        }
        if let flat = files.first(where: { $0.relativePath == "app-config.md" }) {
            return flat
        }
        throw CocoaError(.fileNoSuchFile)
    }

    private static func resolveWeekFiles(
        in files: [VaultFileEntry],
        configurationEntry: VaultFileEntry
    ) -> [VaultFileEntry] {
        if configurationEntry.relativePath == "app-config.md" {
            return files
                .filter { $0.relativePath != configurationEntry.relativePath }
                .sorted { $0.relativePath < $1.relativePath }
        }
        return files
            .filter { $0.relativePath.hasPrefix("Weeks/") }
            .sorted { $0.relativePath < $1.relativePath }
    }

    static func bundledVaultURL() -> URL? {
        guard let resourceURL = Bundle.module.resourceURL else { return nil }
        let fileManager = FileManager.default

        let nestedVaultURL = resourceURL.appendingPathComponent("Vault", isDirectory: true)
        let nestedConfigURL = nestedVaultURL
            .appendingPathComponent("Config", isDirectory: true)
            .appendingPathComponent("app-config.md")
        if fileManager.fileExists(atPath: nestedConfigURL.path) {
            return nestedVaultURL
        }

        let flatConfigURL = resourceURL.appendingPathComponent("app-config.md")
        if fileManager.fileExists(atPath: flatConfigURL.path) {
            return resourceURL
        }

        return nil
    }

    private static func loadConfiguration(from url: URL) throws -> VaultConfiguration {
        let document = try parseMarkdown(at: url)
        let metadata = document.metadata

        let labels = StudyLabels(
            planTabTitle: metadata["label_plan_tab"] ?? StudyLabels.default.planTabTitle,
            vaultTabTitle: metadata["label_vault_tab"] ?? StudyLabels.default.vaultTabTitle,
            planNavigationTitle: metadata["label_plan_navigation"] ?? StudyLabels.default.planNavigationTitle,
            selectWeekTitle: metadata["label_select_week_title"] ?? StudyLabels.default.selectWeekTitle,
            selectWeekDescription: metadata["label_select_week_description"] ?? StudyLabels.default.selectWeekDescription,
            referencesTitle: metadata["label_references"] ?? StudyLabels.default.referencesTitle,
            glossaryTitle: metadata["label_glossary"] ?? StudyLabels.default.glossaryTitle,
            dailyChecklistTitle: metadata["label_daily_checklist"] ?? StudyLabels.default.dailyChecklistTitle,
            resetWeekAction: metadata["label_reset_week"] ?? StudyLabels.default.resetWeekAction,
            studyGuideTitle: metadata["label_study_guide"] ?? StudyLabels.default.studyGuideTitle,
            vaultLibraryTitle: metadata["label_vault_library"] ?? StudyLabels.default.vaultLibraryTitle,
            vaultFilesTitle: metadata["label_vault_files"] ?? StudyLabels.default.vaultFilesTitle,
            vaultEditorTitle: metadata["label_vault_editor"] ?? StudyLabels.default.vaultEditorTitle,
            sourceLabel: metadata["label_source"] ?? StudyLabels.default.sourceLabel,
            makeEditableAction: metadata["label_make_editable"] ?? StudyLabels.default.makeEditableAction,
            chooseFolderAction: metadata["label_choose_folder"] ?? StudyLabels.default.chooseFolderAction,
            resetToBundledAction: metadata["label_reset_bundle"] ?? StudyLabels.default.resetToBundledAction,
            reloadVaultAction: metadata["label_reload_vault"] ?? StudyLabels.default.reloadVaultAction,
            appearanceLabel: metadata["label_appearance"] ?? StudyLabels.default.appearanceLabel,
            saveFileAction: metadata["label_save_file"] ?? StudyLabels.default.saveFileAction,
            readOnlyNotice: metadata["label_read_only_notice"] ?? StudyLabels.default.readOnlyNotice,
            noFileSelectedTitle: metadata["label_no_file_selected_title"] ?? StudyLabels.default.noFileSelectedTitle,
            noFileSelectedDescription: metadata["label_no_file_selected_description"] ?? StudyLabels.default.noFileSelectedDescription,
            previewModeTitle: metadata["label_preview"] ?? StudyLabels.default.previewModeTitle,
            editModeTitle: metadata["label_edit"] ?? StudyLabels.default.editModeTitle,
            outputLabel: metadata["label_output"] ?? StudyLabels.default.outputLabel
        )

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let taskTemplates = [
            (
                metadata["task_read_title"] ?? "Ler o bloco principal do tema",
                metadata["task_read_note_template"] ?? "Foque em {title_lowercased} e registre os termos que ainda estão frágeis."
            ),
            (
                metadata["task_practice_title"] ?? "Executar uma atividade prática",
                metadata["task_practice_note_template"] ?? "Conecte a leitura à prática usando o objetivo: {objective}"
            ),
            (
                metadata["task_record_title"] ?? "Registrar uma saída objetiva",
                metadata["task_record_note_template"] ?? "Atualize suas notas com um resultado verificável: {deliverable}"
            )
        ]

        return VaultConfiguration(
            title: metadata["title"] ?? "Apple OS Developer Track",
            startDate: formatter.date(from: metadata["start_date"] ?? "") ?? .now,
            scheduleLabel: metadata["schedule_label"] ?? "Bloco diário sugerido: 08:00-09:30",
            labels: labels,
            dayTitlePrefix: metadata["day_title_prefix"] ?? "Dia",
            phaseLabels: parseList(metadata["phase_labels"] ?? ""),
            taskTemplates: taskTemplates
        )
    }

    private static func loadWeek(from url: URL, configuration: VaultConfiguration) throws -> WeekPlan {
        let document = try parseMarkdown(at: url)
        let metadata = document.metadata
        let weekNumber = Int(metadata["week_number"] ?? "") ?? 1
        let title = metadata["title"] ?? "Semana \(weekNumber)"
        let objective = metadata["objective"] ?? ""
        let deliverable = metadata["deliverable"] ?? ""
        let glossary = parseList(metadata["glossary"] ?? "")
        let references = parseReferences(metadata["references"] ?? "")
        let tags = parseList(metadata["tags"] ?? "")
        let activities = parseList(metadata["activities"] ?? "")
        let sourceTree = metadata["source_tree"].flatMap { $0.isEmpty ? nil : $0 }
        let relatedFiles = parseList(metadata["related_files"] ?? "")

        let startOffset = (weekNumber - 1) * configuration.phaseLabels.count
        let days = configuration.phaseLabels.enumerated().map { index, phase in
            makeDay(
                weekNumber: weekNumber,
                dayIndex: index,
                phase: phase,
                configuration: configuration,
                title: title,
                objective: objective,
                deliverable: deliverable,
                dateOffset: startOffset + index
            )
        }

        return WeekPlan(
            id: "week-\(weekNumber)",
            weekNumber: weekNumber,
            title: title,
            objective: objective,
            deliverable: deliverable,
            references: references,
            glossary: glossary,
            studyText: document.body.trimmingCharacters(in: .whitespacesAndNewlines),
            days: days,
            tags: tags,
            activities: activities,
            sourceTree: sourceTree,
            relatedFiles: relatedFiles
        )
    }

    private static func makeDay(
        weekNumber: Int,
        dayIndex: Int,
        phase: String,
        configuration: VaultConfiguration,
        title: String,
        objective: String,
        deliverable: String,
        dateOffset: Int
    ) -> StudyDayPlan {
        let baseID = "week-\(weekNumber)-day-\(dayIndex + 1)"
        let tasks = configuration.taskTemplates.enumerated().map { offset, template in
            StudyTask(
                id: "\(baseID)-task-\(offset + 1)",
                title: "\(phase): \(template.title)",
                note: render(
                    template: template.noteTemplate,
                    title: title,
                    objective: objective,
                    deliverable: deliverable
                )
            )
        }

        return StudyDayPlan(
            id: baseID,
            title: "\(configuration.dayTitlePrefix) \(dayIndex + 1)",
            phase: phase,
            dateOffset: dateOffset,
            focus: objective,
            output: deliverable,
            tasks: tasks
        )
    }

    private static func render(template: String, title: String, objective: String, deliverable: String) -> String {
        template
            .replacingOccurrences(of: "{title}", with: title)
            .replacingOccurrences(of: "{title_lowercased}", with: title.lowercased())
            .replacingOccurrences(of: "{objective}", with: objective)
            .replacingOccurrences(of: "{deliverable}", with: deliverable)
    }

    private static func parseMarkdown(at url: URL) throws -> MarkdownDocument {
        let text = try String(contentsOf: url, encoding: .utf8)
        return parseMarkdown(text)
    }

    private static func parseMarkdown(_ text: String) -> MarkdownDocument {
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        guard normalized.hasPrefix("---\n") else {
            return MarkdownDocument(metadata: [:], body: normalized)
        }

        let searchStart = normalized.index(normalized.startIndex, offsetBy: 4)
        guard let footerRange = normalized.range(of: "\n---\n", range: searchStart..<normalized.endIndex) else {
            return MarkdownDocument(metadata: [:], body: normalized)
        }

        let metadataText = String(normalized[searchStart..<footerRange.lowerBound])
        let bodyStart = footerRange.upperBound
        let body = String(normalized[bodyStart...])
        let metadata = metadataText
            .split(separator: "\n", omittingEmptySubsequences: false)
            .reduce(into: [String: String]()) { partial, line in
                let parts = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
                guard let key = parts.first else { return }
                let value = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : ""
                partial[String(key).trimmingCharacters(in: .whitespaces)] = value
            }

        return MarkdownDocument(metadata: metadata, body: body)
    }

    private static func parseList(_ value: String) -> [String] {
        value
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    private static func parseReferences(_ value: String) -> [ReferenceLink] {
        value
            .components(separatedBy: "||")
            .compactMap { item in
                let parts = item.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                guard parts.count >= 2 else { return nil }
                return ReferenceLink(title: parts[0], url: parts[1])
            }
    }

    private static func enumerateMarkdownFiles(in rootURL: URL) throws -> [VaultFileEntry] {
        guard let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return enumerator.compactMap { item in
            guard let url = item as? URL, url.pathExtension.lowercased() == "md" else { return nil }
            let relativePath = relativePath(from: rootURL, to: url)
            return VaultFileEntry(id: relativePath, relativePath: relativePath, url: url)
        }
    }

    private static func relativePath(from baseURL: URL, to targetURL: URL) -> String {
        let basePath = baseURL.standardizedFileURL.path
        let targetPath = targetURL.standardizedFileURL.path

        guard targetPath.hasPrefix(basePath) else {
            return targetURL.lastPathComponent
        }

        let trimmed = targetPath.dropFirst(basePath.count).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed
    }
}
