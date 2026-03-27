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
    let saveFileAction: String
    let readOnlyNotice: String
    let noFileSelectedTitle: String
    let noFileSelectedDescription: String
    let previewModeTitle: String
    let editModeTitle: String
    let outputLabel: String

    static let `default` = StudyLabels(
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
        saveFileAction: "Salvar arquivo",
        readOnlyNotice: "O vault integrado do app é somente leitura. Crie uma cópia local ou conecte uma pasta externa para editar.",
        noFileSelectedTitle: "Selecione um arquivo",
        noFileSelectedDescription: "Abra um markdown no painel lateral para visualizar ou editar seu conteúdo.",
        previewModeTitle: "Visualizar",
        editModeTitle: "Editar",
        outputLabel: "Saída"
    )
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

    var displayName: String {
        switch self {
        case .automatic:
            return "Automático"
        case .light:
            return "Claro"
        case .dark:
            return "Escuro"
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
