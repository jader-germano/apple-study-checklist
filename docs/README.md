# Mapa da Documentação

This repository organizes documentation by `category` and `scope`.

The goal is simple:

- small docs stay easy to find
- large doc sets can grow without collapsing into one flat folder
- each important workflow can point to related code, tests, and API docs

## Categorias

- `product/`: user goals, constraints, story maps, product rules
- `design/`: interaction, UI, Figma, visual behavior
- `engineering/`: implementation workflow, testing, architecture rules
- `architecture/`: system-level structure and boundaries
- `api/`: module-facing behavior, data contracts, integration surfaces
- `reference/`: external standards, tooling patterns, future portal options

## Escopos

- `repository`: rules that apply to the whole repo
- `system`: cross-feature architecture and workflow
- `feature`: a product slice such as the vault workspace
- `component`: a single type, module, or UI area

## Regra de rastreabilidade

When a document describes shipped behavior, it should point to:

1. the related source files
2. the related tests
3. the related API docs or DocC article when applicable

## Hierarquia atual

```text
docs/
├── README.md
├── architecture/
│   ├── README.md
│   └── system-overview.md
├── api/
│   ├── README.md
│   └── vault-workspace-api.md
├── design/
│   ├── README.md
│   ├── figma-prototype-brief.md
│   └── system-ui-ux-spec.md
├── engineering/
│   ├── README.md
│   ├── project-patterns.md
│   ├── tdd-workflow.md
│   └── test-architecture.md
├── product/
│   ├── README.md
│   ├── dos-and-donts.md
│   └── user-story-map.md
└── reference/
    ├── README.md
    └── external-standards.md
```

## Fluxo de atualização

For a new system or feature:

1. update the closest product or architecture document
2. add or update the matching tests
3. update the API-facing document if the contract changed
4. update the DocC catalog when the change affects developer-facing structure
