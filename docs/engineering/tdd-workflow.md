# TDD Workflow

## Rule

New implementation work in this repository must be driven by tests first.

## Loop

1. Define the smallest behavior change.
2. Add or update the user story and acceptance criteria.
3. Write the first failing test.
4. Implement the minimum code required to make the test pass.
5. Refactor while keeping tests green.
6. Update the relevant markdown docs in this folder and in the FrankMD vault.

## Test slices

- Domain and mapping rules:
  - test pure models and markdown parsing first
- Store behavior:
  - test persistence, selection, state transitions, and resets
- Vault operations:
  - use temporary directories and workspace fixtures
- SwiftUI integration:
  - keep view logic thin and move behavior into testable store or service types

## Done criteria

- Failing test existed before the implementation
- New behavior has at least one focused automated test
- Existing tests still pass
- Documentation and design notes are aligned with the shipped behavior

## Do

- Keep tests small and explicit
- Prefer one behavior per test
- Make side effects injectable when they block testing
- Use temporary filesystem fixtures for vault scenarios
- Treat red-green-refactor as a release gate

## Don't

- Ship new behavior that only has manual validation
- Hide new logic inside SwiftUI views when it can live in stores or services
- Add broad screenshot-style tests before core behavior is covered
- Couple filesystem, parsing, and rendering logic into one type
- Change the docs only after implementation is complete
