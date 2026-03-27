# Project Patterns

## Product shape

- One product
- One repository
- Shared domain and content layer
- Platform-specific UI adaptations when needed

## Architecture patterns

### Domain model first

- `Models.swift` remains the stable contract for study plans, days, tasks, labels, and vault files.
- Markdown loaders and vault services must map into the domain model instead of inventing UI-specific structures.

### Store as behavior boundary

- `StudyStore` owns checklist progress, workspace state, appearance, and vault integration decisions.
- `StudyVaultLoader` owns markdown-to-model mapping.
- Future git-specific behavior should move into a dedicated service boundary instead of growing inside views.

### Thin views

- SwiftUI views should compose layout and bind to state.
- Parsing, filesystem traversal, and persistence logic should not expand inside view bodies.

### Service seams for testability

- Filesystem operations should be isolated behind helper methods or service types.
- New markdown import logic should be created behind a provider seam before UI integration.
- Future versioning workflows should be abstracted enough to run against temporary repositories in tests.

### Platform adapters

- macOS-specific APIs stay isolated.
- iOS and visionOS support should be added by replacing platform adapters, not by duplicating the app.

## Do

- Reuse the shared model layer
- Prefer small services with one reason to change
- Keep vault actions explicit and visible
- Version markdown changes intentionally
- Document every architectural deviation

## Don't

- Fork the product into separate apps for iPhone, iPad, and macOS
- Put file loading rules into `ContentView`
- Let UI copy become the storage contract
- Merge UI redesign and storage redesign into the same slice when they can be separated
- Introduce visionOS-specific patterns into the shared flow without a dedicated adapter
