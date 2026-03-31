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
- When a workflow needs an editable vault copy, inject a per-test vault path instead of relying on a shared `Application Support/AppleStudyChecklist/Vault` location.
- Name tests after the workflow or state transition they prove.

## Paralelismo

- Integration tests in this repository are expected to remain safe under parallel execution.
- Avoid shared writable paths across tests, even when the production app uses a fixed default location.
- Prefer constructor injection or explicit test-only seams for filesystem destinations rather than mutating global process state.

## Rastreabilidade

Each new feature slice should add or update tests in the closest layer that owns the behavior:

- parser or metadata change: `Unit`
- persisted state or workflow change: `Integration`
- future view-model orchestration: add a dedicated integration file for that scene

Do not create a new test layer unless the production code has a matching architectural seam.
