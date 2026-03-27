# Apple Study Checklist

App macOS em SwiftUI para acompanhar um cronograma de estudo focado em sistema operacional e desenvolvimento para o ecossistema Apple.

## O que o app faz

- organiza um plano de 12 semanas;
- mostra a data real de cada bloco de estudo;
- oferece checklist persistente por tarefa;
- resume progresso por semana;
- expõe links de referência e glossário de cada tema.

## Como abrir

1. Abra o diretório do pacote no Xcode:
   - `/Users/philipegermano/Library/Mobile Documents/com~apple~CloudDocs/code/apple-study-checklist`
2. Ou rode pelo terminal:
   - `swift run`

## Documentacao de trabalho

- `docs/engineering/README.md`
- `docs/engineering/tdd-workflow.md`
- `docs/engineering/project-patterns.md`
- `docs/product/user-story-map.md`
- `docs/product/dos-and-donts.md`
- `docs/design/figma-prototype-brief.md`
- `docs/design/system-ui-ux-spec.md`

Novas features devem nascer a partir dessa base: historia, criterio, teste falhando primeiro, implementacao minima e refactor.

## Persistência

O progresso do checklist é salvo em:

- `~/Library/Application Support/AppleStudyChecklist/progress.json`

## Cronograma inicial

- Início: `2026-03-28`
- Bloco diário sugerido: `08:00-09:30`
- Duração do programa: `12 semanas`
