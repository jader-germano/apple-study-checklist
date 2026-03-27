import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#endif

struct VaultDocument: Identifiable, Hashable {
    let url: URL
    let relativePath: String

    var id: String { relativePath }
    var displayName: String { url.deletingPathExtension().lastPathComponent }
}

@MainActor
final class VaultStore: ObservableObject {
    @Published private(set) var rootURL: URL?
    @Published private(set) var documents: [VaultDocument] = []
    @Published var selectedDocumentID: String?
    @Published private(set) var editorText = ""
    @Published private(set) var statusMessage = "Abra um vault Markdown local."
    @Published private(set) var hasUnsavedChanges = false

    private let rootDefaultsKey = "apple-study-checklist.vault-root-path"

    var selectedDocument: VaultDocument? {
        documents.first { $0.id == selectedDocumentID }
    }

    init() {
        restoreRootURL()
    }

    func updateEditorText(_ newValue: String) {
        guard newValue != editorText else { return }
        editorText = newValue
        hasUnsavedChanges = true
    }

    func chooseRootFolder() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Abrir vault"
        panel.message = "Selecione a pasta raiz do vault Markdown."

        guard panel.runModal() == .OK, let url = panel.url else {
            statusMessage = "Seleção de vault cancelada."
            return
        }

        setRootURL(url)
        #else
        statusMessage = "Seleção de pasta será adicionada para iOS em uma fase posterior."
        #endif
    }

    func reloadDocuments() {
        guard let rootURL else {
            documents = []
            selectedDocumentID = nil
            editorText = ""
            statusMessage = "Abra um vault Markdown local."
            return
        }

        let discovered = discoverMarkdownDocuments(in: rootURL)
        documents = discovered

        if let selectedDocumentID, discovered.contains(where: { $0.id == selectedDocumentID }) {
            loadSelectedDocument()
        } else if let first = discovered.first {
            selectedDocumentID = first.id
            loadSelectedDocument()
        } else {
            selectedDocumentID = nil
            editorText = ""
            statusMessage = "Nenhum arquivo .md encontrado em \(rootURL.lastPathComponent)."
            hasUnsavedChanges = false
        }
    }

    func selectDocument(id: String?) {
        selectedDocumentID = id
        loadSelectedDocument()
    }

    @discardableResult
    func saveCurrentDocument() -> Bool {
        guard let document = selectedDocument else {
            statusMessage = "Nenhum documento selecionado para salvar."
            return false
        }

        do {
            try editorText.write(to: document.url, atomically: true, encoding: .utf8)
            hasUnsavedChanges = false
            statusMessage = "Arquivo salvo: \(document.relativePath)"
            return true
        } catch {
            statusMessage = "Falha ao salvar \(document.relativePath): \(error.localizedDescription)"
            return false
        }
    }

    func saveAndCommitCurrentDocument() {
        guard let document = selectedDocument else {
            statusMessage = "Nenhum documento selecionado para versionar."
            return
        }

        guard saveCurrentDocument() else { return }
        _ = commit(paths: [document.relativePath], message: "vault: update \(document.relativePath)")
    }

    func commitAllVaultChanges() {
        guard let rootURL else {
            statusMessage = "Abra um vault antes de commitar."
            return
        }

        guard let repoRoot = resolveGitRepositoryRoot(for: rootURL) else {
            statusMessage = "Nenhum repositório Git encontrado para o vault."
            return
        }

        let stagedPath = relativePath(from: repoRoot, to: rootURL)
        guard runGit(arguments: ["add", "--", stagedPath], at: repoRoot).status == 0 else {
            statusMessage = "Falha ao preparar alterações do vault para commit."
            return
        }

        let diff = runGit(arguments: ["diff", "--cached", "--quiet"], at: repoRoot)
        guard diff.status != 0 else {
            statusMessage = "Nenhuma alteração pendente no vault para commitar."
            return
        }

        let commit = runGit(arguments: ["commit", "-m", "vault: update markdown workspace"], at: repoRoot)
        statusMessage = commit.status == 0
            ? "Commit do vault concluído."
            : "Falha ao commitar vault: \(commit.stderr.isEmpty ? commit.stdout : commit.stderr)"
    }

    private func restoreRootURL() {
        guard let storedPath = UserDefaults.standard.string(forKey: rootDefaultsKey), storedPath.isEmpty == false else {
            return
        }

        let url = URL(fileURLWithPath: storedPath, isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        rootURL = url
        reloadDocuments()
    }

    private func setRootURL(_ url: URL) {
        rootURL = url
        UserDefaults.standard.set(url.path, forKey: rootDefaultsKey)
        statusMessage = "Vault ativo: \(url.path)"
        reloadDocuments()
    }

    private func loadSelectedDocument() {
        guard let document = selectedDocument else {
            editorText = ""
            hasUnsavedChanges = false
            return
        }

        do {
            editorText = try String(contentsOf: document.url, encoding: .utf8)
            hasUnsavedChanges = false
            statusMessage = "Editando \(document.relativePath)"
        } catch {
            editorText = ""
            hasUnsavedChanges = false
            statusMessage = "Falha ao abrir \(document.relativePath): \(error.localizedDescription)"
        }
    }

    private func discoverMarkdownDocuments(in rootURL: URL) -> [VaultDocument] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var results: [VaultDocument] = []

        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension.lowercased() == "md" else { continue }
            let relative = relativePath(from: rootURL, to: fileURL)
            results.append(VaultDocument(url: fileURL, relativePath: relative))
        }

        return results.sorted { $0.relativePath.localizedCaseInsensitiveCompare($1.relativePath) == .orderedAscending }
    }

    @discardableResult
    private func commit(paths: [String], message: String) -> Bool {
        guard let rootURL else {
            statusMessage = "Abra um vault antes de commitar."
            return false
        }

        guard let repoRoot = resolveGitRepositoryRoot(for: rootURL) else {
            statusMessage = "Nenhum repositório Git encontrado para o vault."
            return false
        }

        let relativeVaultRoot = relativePath(from: repoRoot, to: rootURL)
        let repoRelativePaths = paths.map { path in
            relativeVaultRoot.isEmpty ? path : "\(relativeVaultRoot)/\(path)"
        }

        let add = runGit(arguments: ["add", "--"] + repoRelativePaths, at: repoRoot)
        guard add.status == 0 else {
            statusMessage = "Falha ao preparar commit: \(add.stderr.isEmpty ? add.stdout : add.stderr)"
            return false
        }

        let diff = runGit(arguments: ["diff", "--cached", "--quiet"], at: repoRoot)
        guard diff.status != 0 else {
            statusMessage = "Nenhuma alteração staged para commit."
            return false
        }

        let commit = runGit(arguments: ["commit", "-m", message], at: repoRoot)
        let output = commit.stderr.isEmpty ? commit.stdout : commit.stderr
        statusMessage = commit.status == 0 ? "Commit concluído: \(message)" : "Falha ao commitar: \(output)"
        return commit.status == 0
    }

    private func resolveGitRepositoryRoot(for url: URL) -> URL? {
        let result = runGit(arguments: ["rev-parse", "--show-toplevel"], at: url)
        guard result.status == 0 else { return nil }
        let rootPath = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rootPath.isEmpty == false else { return nil }
        return URL(fileURLWithPath: rootPath, isDirectory: true)
    }

    private func relativePath(from baseURL: URL, to targetURL: URL) -> String {
        let basePath = baseURL.standardizedFileURL.path
        let targetPath = targetURL.standardizedFileURL.path

        guard targetPath.hasPrefix(basePath) else {
            return targetURL.lastPathComponent
        }

        let trimmed = targetPath.dropFirst(basePath.count).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "." : trimmed
    }

    private func runGit(arguments: [String], at workingDirectory: URL) -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git"] + arguments
        process.currentDirectoryURL = workingDirectory

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return (1, "", error.localizedDescription)
        }

        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return (process.terminationStatus, stdout, stderr)
    }
}
