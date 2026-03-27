# User Story Map

## Product goals

- Help the user follow a study program with low friction
- Keep study material and labels editable as markdown
- Keep the workspace local-first
- Prepare the product for Apple-platform expansion without losing one-product coherence

## Epics and stories

### 1. Study planning

- As a learner, I want to see the study program by week so I can understand my progress.
- As a learner, I want to see daily tasks with dates so I can act on a concrete plan.
- As a learner, I want references, glossary terms, and study text near the task context.

### 2. Markdown-backed content

- As a learner, I want the study text and labels to come from markdown so I can evolve the curriculum without recompiling everything.
- As a maintainer, I want markdown changes to map into stable app models so the UI stays coherent.

### 3. Vault workspace

- As a learner, I want to browse markdown files inside the app so I can stay in one workflow.
- As a learner, I want to edit a markdown file and preview it so I can validate the content before saving.
- As a maintainer, I want to version vault changes in focused slices.

### 4. Cross-platform support

- As a user, I want the same product to work across Apple platforms with behavior adapted to each device.
- As a maintainer, I want shared domain and storage logic so platform expansion does not fork the product.

### 5. Appearance and reading comfort

- As a user, I want light, dark, and automatic appearance modes so the app respects my environment and reading preference.

## MVP acceptance slices

### Local markdown content MVP

- User can load a markdown workspace
- App maps markdown content into `StudyProgram` and `StudyLabels`
- If workspace loading fails, the app falls back safely

### Vault workspace MVP

- User can browse markdown files
- User can preview and edit a file
- User can save without leaving the app

### TDD gate

- Each new slice starts with a failing automated test
- Documentation changes land in the same work cycle
