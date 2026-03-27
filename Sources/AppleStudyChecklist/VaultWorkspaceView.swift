import SwiftUI

struct VaultWorkspaceView: View {
    @ObservedObject var vaultStore: VaultStore
    @State private var showPreview = true

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .navigationTitle("Vault")
        .toolbar {
            ToolbarItemGroup {
                Button("Abrir vault") {
                    vaultStore.chooseRootFolder()
                }

                Button("Recarregar") {
                    vaultStore.reloadDocuments()
                }
                .disabled(vaultStore.rootURL == nil)

                Button("Salvar") {
                    _ = vaultStore.saveCurrentDocument()
                }
                .disabled(vaultStore.selectedDocument == nil || vaultStore.hasUnsavedChanges == false)

                Button("Salvar + Commit") {
                    vaultStore.saveAndCommitCurrentDocument()
                }
                .disabled(vaultStore.selectedDocument == nil)

                Button("Commit All") {
                    vaultStore.commitAllVaultChanges()
                }
                .disabled(vaultStore.rootURL == nil)
            }
        }
    }

    private var sidebar: some View {
        List(
            selection: Binding(
                get: { vaultStore.selectedDocumentID },
                set: { vaultStore.selectDocument(id: $0) }
            )
        ) {
            if let rootURL = vaultStore.rootURL {
                Section(rootURL.lastPathComponent) {
                    ForEach(vaultStore.documents) { document in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(document.displayName)
                            Text(document.relativePath)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(document.id)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Abra um vault",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Selecione uma pasta com arquivos Markdown para leitura, edição e versionamento local.")
                )
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let document = vaultStore.selectedDocument {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(document.relativePath)
                            .font(.headline)
                        Text(vaultStore.statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("Preview", isOn: $showPreview)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }

                HSplitView {
                    TextEditor(
                        text: Binding(
                            get: { vaultStore.editorText },
                            set: { vaultStore.updateEditorText($0) }
                        )
                    )
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 380, minHeight: 420)

                    if showPreview {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                if let rendered = try? AttributedString(markdown: vaultStore.editorText) {
                                    Text(rendered)
                                        .textSelection(.enabled)
                                } else {
                                    Text(vaultStore.editorText)
                                        .textSelection(.enabled)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                        }
                        .frame(minWidth: 320, minHeight: 420)
                    }
                }
            }
            .padding(20)
        } else {
            ContentUnavailableView(
                "Selecione um arquivo Markdown",
                systemImage: "doc.text",
                description: Text("O vault browser permite leitura, edição e commit Git local das alterações.")
            )
        }
    }
}
