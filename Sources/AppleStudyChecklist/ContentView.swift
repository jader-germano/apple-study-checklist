import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var store: StudyStore
    @State private var selectedWeekID: String?

    var body: some View {
        TabView {
            StudyPlanView(store: store, selectedWeekID: $selectedWeekID)
                .tabItem {
                    Label(store.labels.planTabTitle, systemImage: "checklist")
                }

            VaultLibraryView(store: store)
                .tabItem {
                    Label(store.labels.vaultTabTitle, systemImage: "folder")
                }
        }
        .preferredColorScheme(store.appearance.colorScheme)
        .fileImporter(
            isPresented: $store.isImportingVault,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            store.handleVaultImport(result)
        }
        .alert(
            "Apple Study Checklist",
            isPresented: Binding(
                get: { store.lastErrorMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        store.lastErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.lastErrorMessage ?? "")
        }
        .onAppear {
            if selectedWeekID == nil {
                selectedWeekID = store.program.weeks.first?.id
            }
        }
        .onChange(of: store.program.weeks.map(\.id)) { _, weekIDs in
            if let selectedWeekID, weekIDs.contains(selectedWeekID) {
                return
            }
            self.selectedWeekID = weekIDs.first
        }
    }
}

private struct StudyPlanView: View {
    @ObservedObject var store: StudyStore
    @Binding var selectedWeekID: String?

    private var selectedWeek: WeekPlan? {
        store.program.weeks.first { $0.id == selectedWeekID }
    }

    var body: some View {
        NavigationSplitView {
            List(store.program.weeks, selection: $selectedWeekID) { week in
                WeekRowView(week: week, progress: store.progress(for: week))
                    .tag(week.id)
            }
            .navigationTitle(store.labels.planNavigationTitle)
        } detail: {
            if let week = selectedWeek {
                WeekDetailView(program: store.program, week: week, store: store)
            } else {
                ContentUnavailableView(
                    store.labels.selectWeekTitle,
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text(store.labels.selectWeekDescription)
                )
            }
        }
        .toolbar {
            StudyWorkspaceToolbar(store: store)
        }
    }
}

private struct WeekRowView: View {
    let week: WeekPlan
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Semana \(week.weekNumber)")
                    .font(.headline)
                Spacer()
                Text(progress.formatted(.percent.precision(.fractionLength(0))))
                    .foregroundStyle(.secondary)
            }

            Text(week.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
        }
        .padding(.vertical, 4)
    }
}

private struct WeekDetailView: View {
    let program: StudyProgram
    let week: WeekPlan
    @ObservedObject var store: StudyStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                studyGuide
                references
                glossary
                days
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Semana \(week.weekNumber)")
        .toolbar {
            Button(store.labels.resetWeekAction) {
                store.reset(week)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(week.title)
                .font(.largeTitle.bold())

            Text(program.scheduleLabel)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(week.objective)
                .font(.title3)

            Label(week.deliverable, systemImage: "checklist")
                .foregroundStyle(.secondary)

            ProgressView(value: store.progress(for: week))
                .tint(.blue)
        }
    }

    private var studyGuide: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.labels.studyGuideTitle)
                .font(.title2.bold())

            if week.studyText.isEmpty {
                Text(week.objective)
                    .foregroundStyle(.secondary)
            } else {
                Text(markdownAttributedString(week.studyText))
                    .textSelection(.enabled)
            }
        }
    }

    private var references: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.labels.referencesTitle)
                .font(.title2.bold())

            ForEach(week.references) { reference in
                if let url = URL(string: reference.url) {
                    Link(destination: url) {
                        Label(reference.title, systemImage: "link")
                    }
                } else {
                    Label(reference.title, systemImage: "link")
                }
            }
        }
    }

    private var glossary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.labels.glossaryTitle)
                .font(.title2.bold())

            FlowLayout(items: week.glossary) { term in
                Text(term)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }
        }
    }

    private var days: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.labels.dailyChecklistTitle)
                .font(.title2.bold())

            ForEach(week.days) { day in
                DayCardView(
                    program: program,
                    day: day,
                    completedCount: store.completedCount(for: day),
                    totalCount: day.tasks.count,
                    outputLabel: store.labels.outputLabel,
                    store: store
                )
            }
        }
    }

    private func markdownAttributedString(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

private struct DayCardView: View {
    let program: StudyProgram
    let day: StudyDayPlan
    let completedCount: Int
    let totalCount: Int
    let outputLabel: String
    @ObservedObject var store: StudyStore

    private var dateText: String {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .day, value: day.dateOffset, to: program.startDate) ?? program.startDate
        return date.formatted(.dateTime.weekday(.wide).day().month().year())
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(day.title) • \(day.phase)")
                            .font(.headline)
                        Text(dateText)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(completedCount)/\(totalCount)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text(day.focus)
                    .font(.subheadline)

                Label(day.output, systemImage: "doc.text")
                    .foregroundStyle(.secondary)

                Divider()

                ForEach(day.tasks) { task in
                    taskToggle(task: task)
                }
            }
        }
    }

    @ViewBuilder
    private func taskToggle(task: StudyTask) -> some View {
        Toggle(isOn: store.binding(for: task.id)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                Text(task.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
#if os(macOS)
        .toggleStyle(.checkbox)
#endif
    }
}

private struct VaultLibraryView: View {
    @ObservedObject var store: StudyStore

    private var selectedFilePathBinding: Binding<String?> {
        Binding(
            get: { store.selectedFile?.relativePath },
            set: { store.openSelectedFile(relativePath: $0) }
        )
    }

    var body: some View {
        NavigationSplitView {
            Group {
                if store.vaultFiles.isEmpty {
                    VaultWorkspaceStateView(store: store)
                } else {
                    List(store.vaultFiles, selection: selectedFilePathBinding) { file in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.displayName)
                            Text(file.relativePath)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(file.relativePath)
                    }
                }
            }
            .navigationTitle(store.labels.vaultFilesTitle)
        } detail: {
            if store.vaultState.showsSetupActions {
                VaultWorkspaceStateView(store: store)
            } else if let file = store.selectedFile {
                VaultEditorDetailView(store: store, file: file)
            } else {
                ContentUnavailableView(
                    store.labels.noFileSelectedTitle,
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(store.labels.noFileSelectedDescription)
                )
            }
        }
        .toolbar {
            StudyWorkspaceToolbar(store: store)
        }
        .overlay(alignment: .bottomLeading) {
            if store.isVaultEditable == false {
                Text(store.labels.readOnlyNotice)
                    .font(.footnote)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()
            }
        }
    }
}

private struct VaultEditorDetailView: View {
    @ObservedObject var store: StudyStore
    let file: VaultFileEntry
    @State private var mode = EditorMode.preview

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.displayName)
                    .font(.title2.bold())
                Text(file.relativePath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker(store.labels.vaultEditorTitle, selection: $mode) {
                ForEach(EditorMode.allCases) { option in
                    Text(option.title(labels: store.labels)).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch mode {
                case .preview:
                    ScrollView {
                        Text(markdownAttributedString(store.selectedFileContent))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                case .edit:
                    TextEditor(text: $store.selectedFileContent)
                        .font(.body.monospaced())
                        .disabled(store.isVaultEditable == false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            HStack {
                Text("\(store.labels.sourceLabel): \(store.sourceDescription)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(store.labels.saveFileAction) {
                    store.saveSelectedFile()
                }
                .disabled(store.isVaultEditable == false || store.selectedFile == nil)
            }
        }
        .padding(20)
        .navigationTitle(store.labels.vaultLibraryTitle)
    }

    private func markdownAttributedString(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

private struct StudyWorkspaceToolbar: ToolbarContent {
    let store: StudyStore

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Section(store.labels.sourceLabel) {
                    Text(store.sourceDescription)
                }

                Button(store.labels.makeEditableAction) {
                    store.createEditableVaultFromBundle()
                }

                Button(store.labels.chooseFolderAction) {
                    store.chooseVaultFolder()
                }

                Button(store.labels.resetToBundledAction) {
                    store.resetToBundledVault()
                }

                Button(store.labels.reloadVaultAction) {
                    store.reloadWorkspace()
                }

                Section(store.labels.appearanceLabel) {
                    Picker(store.labels.appearanceLabel, selection: Binding(
                        get: { store.appearance },
                        set: { store.updateAppearance($0) }
                    )) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName(for: store.language)).tag(mode)
                        }
                    }
                }

                Section(store.labels.languageLabel) {
                    Picker(store.labels.languageLabel, selection: Binding(
                        get: { store.language },
                        set: { store.updateLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }
            } label: {
                Label("Workspace", systemImage: "slider.horizontal.3")
            }
        }
    }
}

private struct VaultWorkspaceStateView: View {
    @ObservedObject var store: StudyStore

    private var copy: (title: String, description: String, symbol: String) {
        switch store.vaultState {
        case .ready:
            return (
                store.labels.noFileSelectedTitle,
                store.labels.noFileSelectedDescription,
                "doc.text.magnifyingglass"
            )
        case .empty:
            return (
                store.labels.vaultEmptyTitle,
                store.labels.vaultEmptyDescription,
                "folder.badge.questionmark"
            )
        case .setupRequired:
            return (
                store.labels.vaultSetupTitle,
                store.labels.vaultSetupDescription,
                "externaldrive.badge.exclamationmark"
            )
        }
    }

    var body: some View {
        ContentUnavailableView {
            Label(copy.title, systemImage: copy.symbol)
        } description: {
            VStack(spacing: 12) {
                Text(copy.description)
                Text("\(store.labels.sourceLabel): \(store.sourceDescription)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } actions: {
            VaultWorkspaceActionButtons(store: store)
        }
    }
}

private struct VaultWorkspaceActionButtons: View {
    @ObservedObject var store: StudyStore

    var body: some View {
        VStack(spacing: 12) {
            Button(store.labels.makeEditableAction) {
                store.createEditableVaultFromBundle()
            }

            Button(store.labels.chooseFolderAction) {
                store.chooseVaultFolder()
            }

            if store.vaultState != .setupRequired {
                Button(store.labels.resetToBundledAction) {
                    store.resetToBundledVault()
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

private struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private enum EditorMode: String, CaseIterable, Identifiable {
    case preview
    case edit

    var id: String { rawValue }

    func title(labels: StudyLabels) -> String {
        switch self {
        case .preview:
            return labels.previewModeTitle
        case .edit:
            return labels.editModeTitle
        }
    }
}
