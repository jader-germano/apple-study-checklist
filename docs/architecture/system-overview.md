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
- expor um destino editável configurável para testes sem alterar o path padrão usado em runtime

### Vault mapping and editing

- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/VaultStore.swift`
- `Sources/AppleStudyChecklist/VaultWorkspaceView.swift`

Responsabilidades:

- mapear arquivos Markdown do vault para os modelos do app
- suportar acesso ao vault local ou externo
- manter preocupações de versionamento específicas do desktop isoladas do fluxo compartilhado
- manter o fluxo de vault editável validável em testes paralelos sem compartilhar diretórios graváveis

### Bridge remota planejada

- `docs/architecture/secure-container-access.md`

Responsabilidades planejadas:

- expor acesso remoto seguro ao vault do container para iPhone
- manter a origem remota como opcional e isolada do fluxo local-first
- restringir leitura e escrita a um root de arquivos explicitamente autorizado

### Antigravity session hub planejado

- `docs/architecture/antigravity-session-hub.md`

Responsabilidades planejadas:

- expor um menu de sessões semelhante ao Codex, mas alinhado ao design system do app
- ativar provedores como `Codex`, `Claude` e `Gemini` por meio do backend `Antigravity`
- manter memória e contexto compartilhados via vault do hub, sem expor secrets do provedor no cliente
- coordenar estados de `browserSignIn`, permissões de agente e sync de arquivos/versionamento entre dispositivos

### Extração multiplataforma do conceito FrankMD planejada

- `docs/architecture/frankmd-multiplatform-extraction.md`

Responsabilidades planejadas:

- extrair o conceito do `FrankMD` como modelo de vault, biblioteca e histórico
- manter o produto nativo como app, não como porta direta do web app
- preparar a fundação de domínio para Apple platforms agora e Android/Windows depois

## Testes relacionados

- `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`

## API docs relacionados

- `docs/api/vault-workspace-api.md`
- `docs/api/antigravity-session-api.md`
- `docs/architecture/secure-container-access.md`
- `docs/architecture/antigravity-session-hub.md`
- `docs/architecture/frankmd-multiplatform-extraction.md`
- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/VaultWorkspaceAPI.md`
