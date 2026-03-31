# Arquitetura de Testes

## Decisão

Tests in this repository should be organized by layer and responsibility, not unified in a single file.

That matches the current product direction:

- markdown parsing and mapping are pure behaviors
- vault workflows combine filesystem and persisted settings
- UI should stay thin and delegate behavior to testable types

It also matches Apple's test organization model:

- XCTest groups related test methods in focused `XCTestCase` types
- Swift Testing groups related behaviors in suites
- both approaches favor small, related groups over one large catch-all file

## Estrutura no repositório

```text
Tests/AppleStudyChecklistTests/
├── Fixtures/
│   └── TestFixtures.swift
├── Unit/
│   └── StudyVaultLoaderTests.swift
└── Integration/
    ├── StudyStorePersistenceTests.swift
    └── VaultWorkspaceFlowTests.swift
```

## Regras por camada

### Unitário

- Cover pure parsing, mapping, and deterministic transformations.
- Avoid filesystem state unless the file itself is the subject of the test.
- Prefer one focused behavior per test method.

### Integração

- Cover interactions between store, defaults, progress persistence, and vault fixtures.
- Use temporary directories and isolated `UserDefaults` suites.
- Name tests after the workflow or state transition they prove.

## Contrato de cobertura

The repository now enforces `100%` line coverage for the current core scope:

- `Sources/AppleStudyChecklist/Design/ThemeKit.swift`
- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyCatalog.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`
- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`

Validation flow:

- run `swift test --enable-code-coverage`
- read the generated SwiftPM JSON path with `swift test --show-codecov-path`
- validate the scope with `scripts/check_core_coverage.py`

The pure SwiftUI composition files remain outside this `100%` gate for now:

- `ContentView.swift`
- `VaultWorkspaceView.swift`
- `AppleStudyChecklistRootView.swift`

Reason:

- they are thin composition layers
- they currently need a dedicated UI inspection strategy to turn into stable line-coverage gates
- the current quality target is to keep business and workflow logic fully covered first

## Rastreabilidade

Each new feature slice should add or update tests in the closest layer that owns the behavior:

- parser or metadata change: `Unit`
- persisted state or workflow change: `Integration`
- future view-model orchestration: add a dedicated integration file for that scene

Do not create a new test layer unless the production code has a matching architectural seam.
