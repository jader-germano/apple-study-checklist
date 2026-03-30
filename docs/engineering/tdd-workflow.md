# Fluxo de TDD

## Regra

New implementation work in this repository must be driven by tests first.

## Ciclo

1. Define the smallest behavior change.
2. Add or update the user story and acceptance criteria.
3. Write the first failing test.
4. Implement the minimum code required to make the test pass.
5. Refactor while keeping tests green.
6. Update the relevant markdown docs in this folder and in the FrankMD vault.

## Fatias de teste

- Domain and mapping rules:
  - test pure models and markdown parsing first
- Store behavior:
  - test persistence, selection, state transitions, and resets
- Vault operations:
  - use temporary directories and workspace fixtures
- SwiftUI integration:
  - keep view logic thin and move behavior into testable store or service types

## Estrutura de testes

- Group tests by layer and responsibility, not in one catch-all file
- Keep shared fixtures in `Tests/.../Fixtures`
- Keep pure parsing and mapping in `Tests/.../Unit`
- Keep persisted workflows and filesystem-backed flows in `Tests/.../Integration`
- Use file names that match the subject under test so failures are easy to trace

## Critérios de pronto

- Failing test existed before the implementation
- New behavior has at least one focused automated test
- Existing tests still pass
- Documentation and design notes are aligned with the shipped behavior

## Faça

- Keep tests small and explicit
- Prefer one behavior per test
- Make side effects injectable when they block testing
- Use temporary filesystem fixtures for vault scenarios
- Treat red-green-refactor as a release gate

## Não faça

- Ship new behavior that only has manual validation
- Hide new logic inside SwiftUI views when it can live in stores or services
- Add broad screenshot-style tests before core behavior is covered
- Couple filesystem, parsing, and rendering logic into one type
- Change the docs only after implementation is complete
