import Foundation
import SwiftUI

struct ReferenceLink: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let url: String

    init(title: String, url: String) {
        self.id = "\(title)|\(url)"
        self.title = title
        self.url = url
    }
}

struct StudyTask: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let note: String
}

struct StudyDayPlan: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let phase: String
    let dateOffset: Int
    let focus: String
    let output: String
    let tasks: [StudyTask]
}

struct WeekPlan: Identifiable, Hashable, Codable {
    let id: String
    let weekNumber: Int
    let title: String
    let objective: String
    let deliverable: String
    let references: [ReferenceLink]
    let glossary: [String]
    let studyText: String
    let days: [StudyDayPlan]
    var tags: [String]
    var activities: [String]
    var sourceTree: String?
    var relatedFiles: [String]
}

struct StudyProgram: Hashable, Codable {
    let title: String
    let startDate: Date
    let scheduleLabel: String
    let weeks: [WeekPlan]
}

struct StudyLabels: Hashable, Codable {
    let planTabTitle: String
    let vaultTabTitle: String
    let planNavigationTitle: String
    let selectWeekTitle: String
    let selectWeekDescription: String
    let referencesTitle: String
    let glossaryTitle: String
    let dailyChecklistTitle: String
    let resetWeekAction: String
    let studyGuideTitle: String
    let vaultLibraryTitle: String
    let vaultFilesTitle: String
    let vaultEditorTitle: String
    let sourceLabel: String
    let makeEditableAction: String
    let chooseFolderAction: String
    let resetToBundledAction: String
    let reloadVaultAction: String
    let appearanceLabel: String
    let languageLabel: String
    let saveFileAction: String
    let readOnlyNotice: String
    let noFileSelectedTitle: String
    let noFileSelectedDescription: String
    let vaultSetupTitle: String
    let vaultSetupDescription: String
    let vaultEmptyTitle: String
    let vaultEmptyDescription: String
    let previewModeTitle: String
    let editModeTitle: String
    let outputLabel: String

    static let `default` = localizedDefaults(for: .portuguese)

    static func localizedDefaults(for language: AppLanguage) -> StudyLabels {
        switch language {
        case .portuguese:
            return StudyLabels(
                planTabTitle: "Plano",
                vaultTabTitle: "Vault",
                planNavigationTitle: "Plano",
                selectWeekTitle: "Selecione uma semana",
                selectWeekDescription: "O cronograma de estudo aparece por semana com checklist e referências.",
                referencesTitle: "Referências",
                glossaryTitle: "Glossário base",
                dailyChecklistTitle: "Checklist diário",
                resetWeekAction: "Resetar semana",
                studyGuideTitle: "Guia técnico",
                vaultLibraryTitle: "Biblioteca",
                vaultFilesTitle: "Arquivos markdown",
                vaultEditorTitle: "Visualização e edição",
                sourceLabel: "Fonte",
                makeEditableAction: "Criar vault local editável",
                chooseFolderAction: "Conectar pasta markdown",
                resetToBundledAction: "Voltar ao vault integrado",
                reloadVaultAction: "Recarregar vault",
                appearanceLabel: "Aparência",
                languageLabel: "Idioma",
                saveFileAction: "Salvar arquivo",
                readOnlyNotice: "O vault integrado do app é somente leitura. Crie uma cópia local ou conecte uma pasta externa para editar.",
                noFileSelectedTitle: "Selecione um arquivo",
                noFileSelectedDescription: "Abra um markdown no painel lateral para visualizar ou editar seu conteúdo.",
                vaultSetupTitle: "Nenhum vault disponivel",
                vaultSetupDescription: "Crie uma copia local do vault padrao ou conecte uma pasta Markdown existente para habilitar leitura e edicao.",
                vaultEmptyTitle: "Vault sem arquivos Markdown",
                vaultEmptyDescription: "Esta fonte foi aberta, mas nao ha arquivos .md para exibir. Voce pode conectar outra pasta ou recriar um vault local.",
                previewModeTitle: "Visualizar",
                editModeTitle: "Editar",
                outputLabel: "Saída"
            )
        case .english:
            return StudyLabels(
                planTabTitle: "Plan",
                vaultTabTitle: "Vault",
                planNavigationTitle: "Plan",
                selectWeekTitle: "Select a week",
                selectWeekDescription: "The study schedule is organized by week with checklist items and references.",
                referencesTitle: "References",
                glossaryTitle: "Core glossary",
                dailyChecklistTitle: "Daily checklist",
                resetWeekAction: "Reset week",
                studyGuideTitle: "Technical guide",
                vaultLibraryTitle: "Library",
                vaultFilesTitle: "Markdown files",
                vaultEditorTitle: "Preview and edit",
                sourceLabel: "Source",
                makeEditableAction: "Create editable local vault",
                chooseFolderAction: "Connect markdown folder",
                resetToBundledAction: "Switch back to bundled vault",
                reloadVaultAction: "Reload vault",
                appearanceLabel: "Appearance",
                languageLabel: "Language",
                saveFileAction: "Save file",
                readOnlyNotice: "The bundled vault is read-only. Create a local copy or connect an external folder to edit.",
                noFileSelectedTitle: "Select a file",
                noFileSelectedDescription: "Open a markdown file from the sidebar to preview or edit it.",
                vaultSetupTitle: "No vault available",
                vaultSetupDescription: "Create a local copy of the default vault or connect an existing Markdown folder to enable reading and editing.",
                vaultEmptyTitle: "Vault has no Markdown files",
                vaultEmptyDescription: "This source opened successfully, but there are no .md files to display. You can connect another folder or recreate a local vault.",
                previewModeTitle: "Preview",
                editModeTitle: "Edit",
                outputLabel: "Output"
            )
        }
    }
}

struct VaultFileEntry: Identifiable, Hashable {
    let id: String
    let relativePath: String
    let url: URL

    var displayName: String {
        url.lastPathComponent
    }
}

struct StudyWorkspace {
    let program: StudyProgram
    let labels: StudyLabels
}

enum AppearanceMode: String, CaseIterable, Codable, Identifiable {
    case automatic
    case light
    case dark

    var id: String { rawValue }

    func displayName(for language: AppLanguage) -> String {
        switch self {
        case .automatic:
            return language == .english ? "Automatic" : "Automático"
        case .light:
            return language == .english ? "Light" : "Claro"
        case .dark:
            return language == .english ? "Dark" : "Escuro"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case portuguese = "pt-BR"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .portuguese:
            return "Português (Brasil)"
        case .english:
            return "English"
        }
    }
}

enum VaultWorkspaceState: String, Equatable {
    case ready
    case empty
    case setupRequired

    var showsSetupActions: Bool {
        self != .ready
    }
}
