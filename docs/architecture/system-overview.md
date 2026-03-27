# System Overview

- Category: `architecture`
- Scope: `system`

## Purpose

This document tracks the stable system shape of `apple-study-checklist`.

It should be updated when ownership or flow boundaries move.

## Runtime areas

### App shell

- `Sources/AppleStudyChecklist/AppleStudyChecklistApp.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`

Responsibilities:

- host the main window or scene
- expose checklist and vault workflows
- keep top-level navigation stable across platforms

### Study domain and persistence

- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyCatalog.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`

Responsibilities:

- hold the study program model
- persist task completion and appearance
- coordinate vault state for the UI

### Vault mapping and editing

- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/VaultStore.swift`
- `Sources/AppleStudyChecklist/VaultWorkspaceView.swift`

Responsibilities:

- map markdown vault files into app models
- support local or external vault access
- keep desktop-specific versioning concerns isolated from the shared workflow

## Related tests

- `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`

## Related API docs

- `docs/api/vault-workspace-api.md`
- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/VaultWorkspaceAPI.md`
