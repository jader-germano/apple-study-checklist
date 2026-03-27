# Apple Study Checklist

App SwiftUI para macOS e iOS voltado a um cronograma técnico de estudo sobre sistema operacional e desenvolvimento no ecossistema Apple.

## O que o app faz

- organiza um plano de 12 semanas;
- mostra a data real de cada bloco de estudo;
- oferece checklist persistente por tarefa;
- resume progresso por semana;
- expõe links de referência e glossário de cada tema;
- carrega textos, labels e composição do plano a partir de um vault Markdown;
- permite usar o vault integrado, criar uma cópia local editável ou conectar uma pasta externa;
- inclui área de visualização e edição dos arquivos Markdown dentro do app;
- suporta modo `automatic`, `light` e `dark`.

## Como abrir

1. Abra o diretório do pacote no Xcode:
   - `/Users/philipegermano/Library/Mobile Documents/com~apple~CloudDocs/code/apple-study-checklist`
2. Ou rode pelo terminal para macOS:
   - `swift run`

## Build e teste

- Build SwiftPM:
  - `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build`
- Testes:
  - `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test`
- Build Xcode macOS:
  - `xcodebuild -scheme AppleStudyChecklist -destination 'generic/platform=macOS' CODE_SIGNING_ALLOWED=NO build`
- Build Xcode iOS:
  - `xcodebuild -scheme AppleStudyChecklist -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build`

## Documentacao de trabalho

- `docs/README.md`
- `docs/architecture/README.md`
- `docs/architecture/system-overview.md`
- `docs/api/README.md`
- `docs/api/vault-workspace-api.md`
- `docs/engineering/README.md`
- `docs/engineering/tdd-workflow.md`
- `docs/engineering/project-patterns.md`
- `docs/engineering/test-architecture.md`
- `docs/product/user-story-map.md`
- `docs/product/dos-and-donts.md`
- `docs/product/README.md`
- `docs/design/figma-prototype-brief.md`
- `docs/design/system-ui-ux-spec.md`
- `docs/design/README.md`
- `docs/reference/README.md`
- `docs/reference/external-standards.md`

Novas features devem nascer a partir dessa base: historia, criterio, teste falhando primeiro, implementacao minima e refactor.

## API docs

- DocC catalog:
  - `Sources/AppleStudyChecklist/AppleStudyChecklist.docc`
- Build local:
  - `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild docbuild -scheme AppleStudyChecklist -destination 'generic/platform=macOS'`

## Persistência

O progresso do checklist é salvo em:

- `~/Library/Application Support/AppleStudyChecklist/progress.json`

O vault local editável, quando criado pelo app, fica em:

- `~/Library/Application Support/AppleStudyChecklist/Vault`

O bundle padrão do app inclui um vault Markdown em `Sources/AppleStudyChecklist/Resources/Vault`.

## Cronograma inicial

- Início: `2026-03-28`
- Bloco diário sugerido: `08:00-09:30`
- Duração do programa: `12 semanas`
