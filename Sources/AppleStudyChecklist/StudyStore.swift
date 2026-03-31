import Foundation
import SwiftUI

@MainActor
final class StudyStore: ObservableObject {
    @Published private(set) var program = StudyCatalog.program
    @Published private(set) var labels = StudyLabels.default
    @Published private(set) var vaultFiles: [VaultFileEntry] = []
    @Published private(set) var sourceDescription = "Vault integrado"
    @Published private(set) var isVaultEditable = false
    @Published private(set) var vaultState: VaultWorkspaceState = .ready
    @Published private(set) var selectedFile: VaultFileEntry?
    @Published var selectedFileContent = ""
    @Published var appearance: AppearanceMode
    @Published var language: AppLanguage
    @Published var isImportingVault = false
    @Published var lastErrorMessage: String?
    @Published private var completedTaskIDs: Set<String> = []

    private let saveURL: URL
    private let defaults: UserDefaults
    private let bundledVaultURL: URL?
    private let editableVaultURL: URL
    private let makeBookmarkData: (URL) throws -> Data
    private let resolveBookmarkData: (Data, inout Bool) throws -> URL

    private enum DefaultsKey {
        static let progress = "study-progress"
        static let appearance = "study-appearance"
        static let language = "study-language"
        static let vaultMode = "vault-mode"
        static let externalBookmark = "vault-external-bookmark"
    }

    private enum VaultMode: String {
        case bundled
        case appSupport
        case external
    }

    init(
        saveURL: URL? = nil,
        defaults: UserDefaults = .standard,
        bundledVaultURL: URL? = StudyVaultLoader.bundledVaultURL(),
        loadWorkspaceOnInit: Bool = true,
        editableVaultURL: URL? = nil,
        makeBookmarkData: @escaping (URL) throws -> Data = defaultMakeBookmarkData(for:),
        resolveBookmarkData: @escaping (Data, inout Bool) throws -> URL = defaultResolveBookmarkData(_:isStale:)
    ) {
        self.saveURL = saveURL ?? Self.makeSaveURL()
        self.defaults = defaults
        self.bundledVaultURL = bundledVaultURL
        self.editableVaultURL = editableVaultURL ?? Self.makeEditableVaultURL()
        self.makeBookmarkData = makeBookmarkData
        self.resolveBookmarkData = resolveBookmarkData
        let loadedLanguage = Self.loadLanguage(from: defaults)
        self.appearance = Self.loadAppearance(from: defaults)
        self.language = loadedLanguage
        self.labels = .localizedDefaults(for: loadedLanguage)
        loadProgress()
        if loadWorkspaceOnInit {
            reloadWorkspace()
        }
    }

    func isCompleted(_ taskID: String) -> Bool {
        completedTaskIDs.contains(taskID)
    }

    func binding(for taskID: String) -> Binding<Bool> {
        Binding(
            get: { self.completedTaskIDs.contains(taskID) },
            set: { isOn in
                if isOn {
                    self.completedTaskIDs.insert(taskID)
                } else {
                    self.completedTaskIDs.remove(taskID)
                }
                self.saveProgress()
            }
        )
    }

    func completedCount(for day: StudyDayPlan) -> Int {
        day.tasks.filter { completedTaskIDs.contains($0.id) }.count
    }

    func progress(for week: WeekPlan) -> Double {
        let taskIDs = week.days.flatMap(\.tasks).map(\.id)
        guard taskIDs.isEmpty == false else { return 0 }
        let completed = taskIDs.filter { completedTaskIDs.contains($0) }.count
        return Double(completed) / Double(taskIDs.count)
    }

    func reset(_ week: WeekPlan) {
        let ids = Set(week.days.flatMap(\.tasks).map(\.id))
        completedTaskIDs.subtract(ids)
        saveProgress()
    }

    func updateAppearance(_ mode: AppearanceMode) {
        appearance = mode
        defaults.set(mode.rawValue, forKey: DefaultsKey.appearance)
    }

    func updateLanguage(_ language: AppLanguage) {
        self.language = language
        defaults.set(language.rawValue, forKey: DefaultsKey.language)
        reloadWorkspace()
    }

    func openSelectedFile(relativePath: String?) {
        guard let relativePath else {
            selectedFile = nil
            selectedFileContent = ""
            return
        }

        guard let file = vaultFiles.first(where: { $0.relativePath == relativePath }) else {
            selectedFile = nil
            selectedFileContent = ""
            return
        }

        selectedFile = file
        do {
            selectedFileContent = try withScopedAccess(to: file.url) {
                try String(contentsOf: file.url, encoding: .utf8)
            }
        } catch {
            selectedFileContent = ""
            lastErrorMessage = error.localizedDescription
        }
    }

    func saveSelectedFile() {
        guard let selectedFile else { return }
        guard isVaultEditable else {
            lastErrorMessage = labels.readOnlyNotice
            return
        }

        do {
            try withScopedAccess(to: selectedFile.url) {
                try selectedFileContent.write(to: selectedFile.url, atomically: true, encoding: .utf8)
            }
            reloadWorkspace(preservingFile: selectedFile.relativePath)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func createEditableVaultFromBundle() {
        guard let bundledURL = bundledVaultURL else {
            vaultState = .setupRequired
            sourceDescription = localizedSourceDescription(.setupRequired)
            lastErrorMessage = language == .english
                ? "Could not locate the bundled vault."
                : "Não foi possível localizar o vault integrado."
            return
        }

        let targetURL = editableVaultURL
        do {
            let manager = FileManager.default
            if manager.fileExists(atPath: targetURL.path) == false {
                try manager.copyItem(at: bundledURL, to: targetURL)
            }

            defaults.set(VaultMode.appSupport.rawValue, forKey: DefaultsKey.vaultMode)
            reloadWorkspace()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func chooseVaultFolder() {
        isImportingVault = true
    }

    func handleVaultImport(_ result: Result<[URL], Error>) {
        isImportingVault = false

        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                lastErrorMessage = "Nenhuma pasta foi selecionada."
                return
            }
            do {
                let bookmark = try makeBookmarkData(url)
                defaults.set(bookmark, forKey: DefaultsKey.externalBookmark)
                defaults.set(VaultMode.external.rawValue, forKey: DefaultsKey.vaultMode)
                reloadWorkspace()
            } catch {
                lastErrorMessage = error.localizedDescription
            }
        case .failure(let error):
            lastErrorMessage = error.localizedDescription
        }
    }

    func loadExternalVault(at url: URL) {
        do {
            let payload = try withScopedAccess(to: url) {
                try StudyVaultLoader.load(from: url, language: language)
            }
            program = payload.workspace.program
            labels = payload.workspace.labels
            vaultFiles = payload.files
            isVaultEditable = true
            sourceDescription = localizedSourceDescription(.external)
            vaultState = payload.workspace.program.weeks.isEmpty ? .empty : .ready
            lastErrorMessage = nil
            openSelectedFile(relativePath: selectedFile?.relativePath)
        } catch {
            program = StudyCatalog.program
            labels = .localizedDefaults(for: language)
            vaultFiles = []
            selectedFile = nil
            selectedFileContent = ""
            isVaultEditable = false
            vaultState = .setupRequired
            sourceDescription = localizedSourceDescription(.setupRequired)
            lastErrorMessage = error.localizedDescription
        }
    }

    func resetToBundledVault() {
        defaults.set(VaultMode.bundled.rawValue, forKey: DefaultsKey.vaultMode)
        defaults.removeObject(forKey: DefaultsKey.externalBookmark)
        reloadWorkspace()
    }

    func reloadWorkspace() {
        reloadWorkspace(preservingFile: selectedFile?.relativePath)
    }

    private func reloadWorkspace(preservingFile relativePath: String?) {
        do {
            let source = try resolveVaultSource()
            let payload = try withScopedAccess(to: source.url) {
                try StudyVaultLoader.load(from: source.url, language: language)
            }
            program = payload.workspace.program
            labels = payload.workspace.labels
            vaultFiles = payload.files
            isVaultEditable = source.isEditable
            sourceDescription = source.description
            vaultState = payload.workspace.program.weeks.isEmpty ? .empty : .ready
            openSelectedFile(relativePath: relativePath)
        } catch {
            program = StudyCatalog.program
            labels = .localizedDefaults(for: language)
            vaultFiles = []
            selectedFile = nil
            selectedFileContent = ""
            isVaultEditable = false
            vaultState = .setupRequired
            sourceDescription = localizedSourceDescription(.setupRequired)
            lastErrorMessage = error.localizedDescription
        }
    }

    private func resolveVaultSource() throws -> (url: URL, isEditable: Bool, description: String) {
        let mode = VaultMode(rawValue: defaults.string(forKey: DefaultsKey.vaultMode) ?? "") ?? .bundled
        switch mode {
        case .bundled:
            guard let url = bundledVaultURL else {
                throw CocoaError(.fileNoSuchFile)
            }
            return (url, false, localizedSourceDescription(.bundled))
        case .appSupport:
            return (editableVaultURL, true, localizedSourceDescription(.appSupport))
        case .external:
            guard
                let data = defaults.data(forKey: DefaultsKey.externalBookmark)
            else {
                throw CocoaError(.fileReadNoSuchFile)
            }

            var isStale = false
            let url = try resolveBookmarkData(data, &isStale)

            if isStale {
                let refreshed = try makeBookmarkData(url)
                defaults.set(refreshed, forKey: DefaultsKey.externalBookmark)
            }

            return (url, true, localizedSourceDescription(.external))
        }
    }

    private enum SourceDescriptionKind {
        case bundled
        case appSupport
        case external
        case setupRequired
    }

    private func localizedSourceDescription(_ kind: SourceDescriptionKind) -> String {
        switch (language, kind) {
        case (.english, .bundled):
            return "Bundled vault"
        case (.english, .appSupport):
            return "Local vault in Application Support"
        case (.english, .external):
            return "Connected external vault"
        case (.english, .setupRequired):
            return "No vault configured"
        case (.portuguese, .bundled):
            return "Vault integrado ao app"
        case (.portuguese, .appSupport):
            return "Vault local em Application Support"
        case (.portuguese, .external):
            return "Vault externo conectado"
        case (.portuguese, .setupRequired):
            return "Nenhum vault configurado"
        }
    }

    private func loadProgress() {
        guard
            let data = try? Data(contentsOf: saveURL),
            let payload = try? JSONDecoder().decode(PersistedProgress.self, from: data)
        else {
            return
        }

        completedTaskIDs = Set(payload.completedTaskIDs)
    }

    private func saveProgress() {
        let payload = PersistedProgress(completedTaskIDs: Array(completedTaskIDs).sorted())
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private func withScopedAccess<T>(to url: URL, operation: () throws -> T) throws -> T {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        return try operation()
    }

    private static func loadAppearance(from defaults: UserDefaults) -> AppearanceMode {
        guard
            let rawValue = defaults.string(forKey: DefaultsKey.appearance),
            let appearance = AppearanceMode(rawValue: rawValue)
        else {
            return .automatic
        }

        return appearance
    }

    private static func loadLanguage(from defaults: UserDefaults) -> AppLanguage {
        guard
            let rawValue = defaults.string(forKey: DefaultsKey.language),
            let language = AppLanguage(rawValue: rawValue)
        else {
            return .portuguese
        }

        return language
    }

    static func makeSaveURL(baseURL: URL? = nil, fileManager: FileManager = .default) -> URL {
        let resolvedBaseURL = baseURL ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let folderURL = resolvedBaseURL.appendingPathComponent("AppleStudyChecklist", isDirectory: true)
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        return folderURL.appendingPathComponent("progress.json")
    }

    static func makeEditableVaultURL(baseURL: URL? = nil, fileManager: FileManager = .default) -> URL {
        let resolvedBaseURL = baseURL ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let folderURL = resolvedBaseURL
            .appendingPathComponent("AppleStudyChecklist", isDirectory: true)
            .appendingPathComponent("Vault", isDirectory: true)
        try? fileManager.createDirectory(at: folderURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        return folderURL
    }
}

private struct PersistedProgress: Codable {
    let completedTaskIDs: [String]
}

private func defaultMakeBookmarkData(for url: URL) throws -> Data {
#if os(macOS)
    return try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    )
#else
    return try url.bookmarkData(
        options: [],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    )
#endif
}

private func defaultResolveBookmarkData(_ data: Data, isStale: inout Bool) throws -> URL {
#if os(macOS)
    return try URL(
        resolvingBookmarkData: data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    )
#else
    return try URL(
        resolvingBookmarkData: data,
        options: [],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    )
#endif
}
