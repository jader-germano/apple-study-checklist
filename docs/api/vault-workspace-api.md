# Vault Workspace API

- Category: `api`
- Scope: `feature`

## Purpose

This document describes the current developer-facing contract of the vault workspace.

It is not a network API. It is the internal app-facing contract between markdown content, workspace loading, and the UI.

## Main types

### StudyLabels

Defined in `Sources/AppleStudyChecklist/Models.swift`.

Owns the user-facing labels loaded from markdown metadata or defaults.

### VaultFileEntry

Defined in `Sources/AppleStudyChecklist/Models.swift`.

Represents a markdown file discovered in the current workspace.

### VaultWorkspaceState

Defined in `Sources/AppleStudyChecklist/Models.swift`.

Supported states:

- `ready`
- `empty`
- `setupRequired`

### StudyStore

Defined in `Sources/AppleStudyChecklist/StudyStore.swift`.

UI-facing responsibilities:

- load the active vault source
- expose `vaultFiles`, `selectedFile`, `selectedFileContent`
- expose `sourceDescription`, `isVaultEditable`, `vaultState`
- persist progress and appearance

### StudyVaultLoader

Defined in `Sources/AppleStudyChecklist/StudyVaultLoader.swift`.

Responsibilities:

- read `Config/app-config.md`
- enumerate markdown files
- map `Weeks/*.md` into `WeekPlan`
- build `StudyWorkspace`

## Source modes

The current workspace can come from:

- bundled vault
- local editable copy in Application Support
- external folder imported through the picker

## Traceability

Related code:

- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`
- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`

Related tests:

- `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`

Related DocC:

- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/VaultWorkspaceAPI.md`
