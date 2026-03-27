# Base de Engenharia

This folder is the pre-implementation gate for `apple-study-checklist`.

Every new feature should pass through these artifacts before code changes:

1. user story or workflow update
2. design and UI impact note
3. TDD plan with the first failing test
4. implementation slice
5. refactor and documentation update

## Arquivos

- `tdd-workflow.md`: execution model for red-green-refactor in this repo
- `project-patterns.md`: architecture and project patterns to keep stable
- `test-architecture.md`: how tests are split for traceability and modularity

## Escopo

- Category: `engineering`
- Scope: `repository`

Engineering docs should connect implementation rules to:

- source boundaries
- test boundaries
- API-doc updates when contracts change

## Escopo atual

- Preserve the current app behavior while increasing testability
- Keep markdown-backed study content as the product direction
- Treat the vault workspace as a first-class workflow
- Prepare platform expansion without forking the product
