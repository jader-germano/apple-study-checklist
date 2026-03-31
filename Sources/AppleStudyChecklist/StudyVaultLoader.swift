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
        let language: AppLanguage
    }

    static func load(from vaultURL: URL, language: AppLanguage = .portuguese) throws -> Payload {
        let files = try enumerateMarkdownFiles(in: vaultURL)
        let configFile = try resolveConfigurationFile(in: files)
        let config = try loadConfiguration(from: configFile.url, language: language)
        let weekFiles = resolveWeekFiles(in: files, configurationFile: configFile)
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

    static func bundledVaultURL() -> URL? {
        resolveBundledVaultURL(resourceURL: Bundle.module.resourceURL)
    }

    static func resolveBundledVaultURL(resourceURL: URL?, fileManager: FileManager = .default) -> URL? {
        guard let resourceURL else {
            return nil
        }
        let nestedVaultURL = resourceURL.appendingPathComponent("Vault", isDirectory: true)
        let nestedConfigURL = nestedVaultURL
            .appendingPathComponent("Config", isDirectory: true)
            .appendingPathComponent("app-config.md")

        if fileManager.fileExists(atPath: nestedConfigURL.path) {
            return nestedVaultURL
        }

        let flattenedConfigURL = resourceURL.appendingPathComponent("app-config.md")
        if fileManager.fileExists(atPath: flattenedConfigURL.path) {
            return resourceURL
        }

        return nil
    }

    private static func loadConfiguration(from url: URL, language: AppLanguage) throws -> VaultConfiguration {
        let document = try parseMarkdown(at: url)
        let metadata = document.metadata
        let defaults = StudyLabels.localizedDefaults(for: language)
        let suffix = language == .english ? "_en" : ""

        let labels = StudyLabels(
            planTabTitle: localizedMetadataValue(metadata, key: "label_plan_tab", suffix: suffix) ?? defaults.planTabTitle,
            vaultTabTitle: localizedMetadataValue(metadata, key: "label_vault_tab", suffix: suffix) ?? defaults.vaultTabTitle,
            planNavigationTitle: localizedMetadataValue(metadata, key: "label_plan_navigation", suffix: suffix) ?? defaults.planNavigationTitle,
            selectWeekTitle: localizedMetadataValue(metadata, key: "label_select_week_title", suffix: suffix) ?? defaults.selectWeekTitle,
            selectWeekDescription: localizedMetadataValue(metadata, key: "label_select_week_description", suffix: suffix) ?? defaults.selectWeekDescription,
            referencesTitle: localizedMetadataValue(metadata, key: "label_references", suffix: suffix) ?? defaults.referencesTitle,
            glossaryTitle: localizedMetadataValue(metadata, key: "label_glossary", suffix: suffix) ?? defaults.glossaryTitle,
            dailyChecklistTitle: localizedMetadataValue(metadata, key: "label_daily_checklist", suffix: suffix) ?? defaults.dailyChecklistTitle,
            resetWeekAction: localizedMetadataValue(metadata, key: "label_reset_week", suffix: suffix) ?? defaults.resetWeekAction,
            studyGuideTitle: localizedMetadataValue(metadata, key: "label_study_guide", suffix: suffix) ?? defaults.studyGuideTitle,
            vaultLibraryTitle: localizedMetadataValue(metadata, key: "label_vault_library", suffix: suffix) ?? defaults.vaultLibraryTitle,
            vaultFilesTitle: localizedMetadataValue(metadata, key: "label_vault_files", suffix: suffix) ?? defaults.vaultFilesTitle,
            vaultEditorTitle: localizedMetadataValue(metadata, key: "label_vault_editor", suffix: suffix) ?? defaults.vaultEditorTitle,
            sourceLabel: localizedMetadataValue(metadata, key: "label_source", suffix: suffix) ?? defaults.sourceLabel,
            makeEditableAction: localizedMetadataValue(metadata, key: "label_make_editable", suffix: suffix) ?? defaults.makeEditableAction,
            chooseFolderAction: localizedMetadataValue(metadata, key: "label_choose_folder", suffix: suffix) ?? defaults.chooseFolderAction,
            resetToBundledAction: localizedMetadataValue(metadata, key: "label_reset_bundle", suffix: suffix) ?? defaults.resetToBundledAction,
            reloadVaultAction: localizedMetadataValue(metadata, key: "label_reload_vault", suffix: suffix) ?? defaults.reloadVaultAction,
            appearanceLabel: localizedMetadataValue(metadata, key: "label_appearance", suffix: suffix) ?? defaults.appearanceLabel,
            languageLabel: localizedMetadataValue(metadata, key: "label_language", suffix: suffix) ?? defaults.languageLabel,
            saveFileAction: localizedMetadataValue(metadata, key: "label_save_file", suffix: suffix) ?? defaults.saveFileAction,
            readOnlyNotice: localizedMetadataValue(metadata, key: "label_read_only_notice", suffix: suffix) ?? defaults.readOnlyNotice,
            noFileSelectedTitle: localizedMetadataValue(metadata, key: "label_no_file_selected_title", suffix: suffix) ?? defaults.noFileSelectedTitle,
            noFileSelectedDescription: localizedMetadataValue(metadata, key: "label_no_file_selected_description", suffix: suffix) ?? defaults.noFileSelectedDescription,
            vaultSetupTitle: localizedMetadataValue(metadata, key: "label_vault_setup_title", suffix: suffix) ?? defaults.vaultSetupTitle,
            vaultSetupDescription: localizedMetadataValue(metadata, key: "label_vault_setup_description", suffix: suffix) ?? defaults.vaultSetupDescription,
            vaultEmptyTitle: localizedMetadataValue(metadata, key: "label_vault_empty_title", suffix: suffix) ?? defaults.vaultEmptyTitle,
            vaultEmptyDescription: localizedMetadataValue(metadata, key: "label_vault_empty_description", suffix: suffix) ?? defaults.vaultEmptyDescription,
            previewModeTitle: localizedMetadataValue(metadata, key: "label_preview", suffix: suffix) ?? defaults.previewModeTitle,
            editModeTitle: localizedMetadataValue(metadata, key: "label_edit", suffix: suffix) ?? defaults.editModeTitle,
            outputLabel: localizedMetadataValue(metadata, key: "label_output", suffix: suffix) ?? defaults.outputLabel
        )

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let taskTemplates = [
            (
                localizedMetadataValue(metadata, key: "task_read_title", suffix: suffix)
                    ?? (language == .english ? "Read the main topic block" : "Ler o bloco principal do tema"),
                localizedMetadataValue(metadata, key: "task_read_note_template", suffix: suffix)
                    ?? (language == .english
                        ? "During {phase_lowercased}, focus on {title_lowercased} and write down the weak terms."
                        : "Na etapa de {phase_lowercased}, foque em {title_lowercased} e registre os termos que ainda estão frágeis.")
            ),
            (
                localizedMetadataValue(metadata, key: "task_practice_title", suffix: suffix)
                    ?? (language == .english ? "Run a practical activity" : "Executar uma atividade prática"),
                localizedMetadataValue(metadata, key: "task_practice_note_template", suffix: suffix)
                    ?? (language == .english
                        ? "In {phase_lowercased}, connect the reading to practice using the objective: {objective}"
                        : "Em {phase_lowercased}, conecte a leitura à prática usando o objetivo: {objective}")
            ),
            (
                localizedMetadataValue(metadata, key: "task_record_title", suffix: suffix)
                    ?? (language == .english ? "Record an objective output" : "Registrar uma saída objetiva"),
                localizedMetadataValue(metadata, key: "task_record_note_template", suffix: suffix)
                    ?? (language == .english
                        ? "Close {phase_lowercased} by updating your notes with a verifiable result: {deliverable}"
                        : "Feche {phase_lowercased} atualizando suas notas com um resultado verificável: {deliverable}")
            )
        ]

        return VaultConfiguration(
            title: localizedMetadataValue(metadata, key: "title", suffix: suffix) ?? "Apple OS Developer Track",
            startDate: formatter.date(from: metadata["start_date"] ?? "") ?? .now,
            scheduleLabel: localizedMetadataValue(metadata, key: "schedule_label", suffix: suffix)
                ?? (language == .english ? "Suggested block: 08:00-09:30" : "Bloco diário sugerido: 08:00-09:30"),
            labels: labels,
            dayTitlePrefix: localizedMetadataValue(metadata, key: "day_title_prefix", suffix: suffix)
                ?? (language == .english ? "Day" : "Dia"),
            phaseLabels: parseList(localizedMetadataValue(metadata, key: "phase_labels", suffix: suffix) ?? ""),
            taskTemplates: taskTemplates,
            language: language
        )
    }

    private static func localizedMetadataValue(_ metadata: [String: String], key: String, suffix: String) -> String? {
        if suffix.isEmpty == false, let localizedValue = metadata["\(key)\(suffix)"] {
            return localizedValue
        }
        return metadata[key]
    }

    private static func loadWeek(from url: URL, configuration: VaultConfiguration) throws -> WeekPlan {
        let document = try parseMarkdown(at: url)
        let metadata = document.metadata
        let weekNumber = Int(metadata["week_number"] ?? "") ?? 1
        let suffix = configuration.language == .english ? "_en" : ""
        let title = localizedMetadataValue(metadata, key: "title", suffix: suffix) ?? "Semana \(weekNumber)"
        let objective = localizedMetadataValue(metadata, key: "objective", suffix: suffix) ?? ""
        let deliverable = localizedMetadataValue(metadata, key: "deliverable", suffix: suffix) ?? ""
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
            studyText: (
                localizedMetadataValue(metadata, key: "study_text", suffix: suffix)
                ?? document.body
            ).trimmingCharacters(in: .whitespacesAndNewlines),
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
        let dayTitle = "\(configuration.dayTitlePrefix) \(dayIndex + 1)"
        let tasks = configuration.taskTemplates.enumerated().map { offset, template in
            let renderedNote = render(
                template: template.noteTemplate,
                title: title,
                objective: objective,
                deliverable: deliverable,
                phase: phase,
                dayTitle: dayTitle
            )

            return StudyTask(
                id: "\(baseID)-task-\(offset + 1)",
                title: "\(phase): \(template.title)",
                note: contextualizeTaskNote(
                    renderedNote,
                    phase: phase,
                    language: configuration.language
                )
            )
        }

        return StudyDayPlan(
            id: baseID,
            title: dayTitle,
            phase: phase,
            dateOffset: dateOffset,
            focus: contextualizeFocus(
                objective,
                phase: phase,
                language: configuration.language
            ),
            output: contextualizeOutput(
                deliverable,
                phase: phase,
                language: configuration.language
            ),
            tasks: tasks
        )
    }

    private static func render(
        template: String,
        title: String,
        objective: String,
        deliverable: String,
        phase: String,
        dayTitle: String
    ) -> String {
        template
            .replacingOccurrences(of: "{title}", with: title)
            .replacingOccurrences(of: "{title_lowercased}", with: title.lowercased())
            .replacingOccurrences(of: "{objective}", with: objective)
            .replacingOccurrences(of: "{deliverable}", with: deliverable)
            .replacingOccurrences(of: "{phase}", with: phase)
            .replacingOccurrences(of: "{phase_lowercased}", with: phase.lowercased())
            .replacingOccurrences(of: "{day_title}", with: dayTitle)
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

    private static func contextualizeFocus(
        _ objective: String,
        phase: String,
        language: AppLanguage
    ) -> String {
        guard objective.isEmpty == false else {
            return phase
        }

        if containsPhase(objective, phase: phase) {
            return objective
        }

        switch language {
        case .portuguese, .english:
            return "\(phase): \(objective)"
        }
    }

    private static func contextualizeOutput(
        _ deliverable: String,
        phase: String,
        language: AppLanguage
    ) -> String {
        guard deliverable.isEmpty == false else {
            return phase
        }

        if containsPhase(deliverable, phase: phase) {
            return deliverable
        }

        switch language {
        case .portuguese:
            return "Saída de \(phase.lowercased()): \(deliverable)"
        case .english:
            return "Output for \(phase): \(deliverable)"
        }
    }

    private static func contextualizeTaskNote(
        _ note: String,
        phase: String,
        language: AppLanguage
    ) -> String {
        guard note.isEmpty == false else {
            return note
        }

        if containsPhase(note, phase: phase) {
            return note
        }

        switch language {
        case .portuguese, .english:
            return "\(phase): \(note)"
        }
    }

    private static func containsPhase(_ text: String, phase: String) -> Bool {
        let normalizedText = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let normalizedPhase = phase.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return normalizedText.contains(normalizedPhase)
    }

    static func enumerateMarkdownFiles(in rootURL: URL) throws -> [VaultFileEntry] {
        let items = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )?.allObjects ?? []

        return items.compactMap { item in
            guard let url = item as? URL, url.pathExtension.lowercased() == "md" else { return nil }
            let relativePath = relativePath(from: rootURL, to: url)
            return VaultFileEntry(id: relativePath, relativePath: relativePath, url: url)
        }
    }

    private static func resolveConfigurationFile(in files: [VaultFileEntry]) throws -> VaultFileEntry {
        if let nestedConfiguration = files.first(where: { $0.relativePath == "Config/app-config.md" }) {
            return nestedConfiguration
        }

        if let flattenedConfiguration = files.first(where: { $0.relativePath == "app-config.md" }) {
            return flattenedConfiguration
        }

        throw CocoaError(.fileNoSuchFile)
    }

    private static func resolveWeekFiles(
        in files: [VaultFileEntry],
        configurationFile: VaultFileEntry
    ) -> [VaultFileEntry] {
        if configurationFile.relativePath == "app-config.md" {
            return files
                .filter { $0.relativePath != configurationFile.relativePath }
                .sorted { $0.relativePath < $1.relativePath }
        }

        return files
            .filter { $0.relativePath.hasPrefix("Weeks/") }
            .sorted { $0.relativePath < $1.relativePath }
    }

    static func relativePath(from baseURL: URL, to targetURL: URL) -> String {
        let basePath = baseURL.standardizedFileURL.path
        let targetPath = targetURL.standardizedFileURL.path

        guard targetPath.hasPrefix(basePath) else {
            return targetURL.lastPathComponent
        }

        let trimmed = targetPath.dropFirst(basePath.count).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed
    }
}
