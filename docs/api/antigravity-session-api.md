# API da Sessão Antigravity

- Categoria: `api`
- Escopo: `feature`

## Propósito

Descrever o contrato planejado entre a UI do app e a camada de sessão/menu `Antigravity`.

Esta documentação cobre comportamento esperado de app e gateway, não uma API pública já implementada.

## Tipos principais planejados

### LLMProvider

Valores iniciais:

- `codex`
- `claude`
- `gemini`

### SessionPermissionMode

Valores iniciais:

- `readOnly`
- `planOnly`
- `reviewOnly`
- `sandboxedExecution`

### SessionSyncMode

Valores iniciais:

- `localOnly`
- `fileSync`
- `versionSync`

### AgentSandboxReference

Representa a referência salva para um perfil de permissões e sandbox associado a uma sessão.

### SessionMemorySource

Valores iniciais:

- `bundledVault`
- `localVault`
- `externalVault`
- `remoteVault`
- `sharedFrankVault`

## Operações planejadas

### browserSignIn()

Responsabilidades:

- abrir autenticação via navegador para `Antigravity`
- concluir o callback autenticado no app
- persistir credenciais de sessão no Keychain

### listProviders()

Responsabilidades:

- mostrar provedores configuráveis
- mostrar disponibilidade atual
- mostrar se o provedor está ativo ou não para este usuário

### listSessions()

Responsabilidades:

- listar sessões paralelas
- mostrar dono, objetivo, modo de permissão e estado de sync

### createPlanningSession()

Responsabilidades:

- criar uma nova sessão
- escolher provedor
- escolher memória compartilhada do vault
- escolher perfil de permissão

### attachVaultSource()

Responsabilidades:

- associar a sessão a um root de vault explicitamente autorizado
- impedir caminhos fora do escopo permitido

### refreshSyncStatus()

Responsabilidades:

- buscar estado de `fileSync` ou `versionSync`
- mostrar conflito, atraso ou erro

### fetchHistory()

Responsabilidades:

- listar histórico de mudanças e revisões
- expor de onde veio cada atualização

## Restrições validadas

- `OpenAI` não deve ser chamado do cliente com API key embutida
- `Anthropic` também depende de API key e deve ficar atrás do backend
- o app deve autenticar contra `Antigravity`, não diretamente contra múltiplos provedores
- sync deve continuar orientado a arquivo Markdown, não a acesso bruto ao container

## Semântica de sync planejada

### fileSync

- o arquivo editado localmente não é considerado imediatamente refletido em outros dispositivos
- a UI deve indicar `pending`, `synced` ou `failed`

### versionSync

- cada arquivo possui identidade de revisão
- alterações concorrentes geram estado de conflito
- resolução de conflito deve preservar histórico visível

## Rastreabilidade

Arquitetura relacionada:

- `docs/architecture/antigravity-session-hub.md`
- `docs/architecture/secure-container-access.md`

Design relacionado:

- `docs/design/system-ui-ux-spec.md`
- `docs/design/figma-prototype-brief.md`

DocC relacionado:

- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/AntigravitySessionHub.md`

Status:

- contrato planejado
- sem endpoint implementado ainda
