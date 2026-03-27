# Visão Geral do Sistema

- Categoria: `architecture`
- Escopo: `system`

## Propósito

Este documento acompanha a forma estável do sistema `apple-study-checklist`.

Ele deve ser atualizado quando fronteiras de responsabilidade ou fluxos mudarem.

## Áreas de runtime

### App shell

- `Apps/iOS/AppleStudyChecklistiOSApp.swift`
- `Sources/AppleStudyChecklist/AppleStudyChecklistRootView.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`

Responsabilidades:

- hospedar a janela ou cena principal
- expor os fluxos de checklist e vault
- manter a navegação de topo estável entre plataformas

### Study domain and persistence

- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyCatalog.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`

Responsabilidades:

- manter o modelo do programa de estudo
- persistir conclusão de tarefas, aparência e idioma
- coordenar o estado do vault para a UI

### Vault mapping and editing

- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/VaultStore.swift`
- `Sources/AppleStudyChecklist/VaultWorkspaceView.swift`

Responsabilidades:

- mapear arquivos Markdown do vault para os modelos do app
- suportar acesso ao vault local ou externo
- manter preocupações de versionamento específicas do desktop isoladas do fluxo compartilhado

## Testes relacionados

- `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`

## API docs relacionados

- `docs/api/vault-workspace-api.md`
- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/VaultWorkspaceAPI.md`
