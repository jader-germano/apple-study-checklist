# Plano de Implementação

## Status

Este documento define o plano arquitetural para a grande refatoração do
`Apple Study Checklist` em um app genérico de trilhas de estudo, orientado por
vault local e orquestrado por sessão de I.A.

Escopo deste artefato:

- planejar antes de codar
- definir novas fronteiras de pacote, domínio e managers
- amarrar TDD, privacidade, filesystem, EventKit e sessão LLM
- incorporar o gate de prototipação e os padrões visuais da sessão
  `Claude.app`
- referenciar a migração operacional `GitHub -> GitLab`
- preparar a evolução do checklist para uma trilha guiada por árvore
  documental, expansões e metadata relacional

Fora de escopo neste momento:

- criar novas views
- alterar produção
- reestruturar targets ou persistência antes de aprovação

Implementação só deve começar após aprovação explícita do usuário: `Ok`.

## Leitura da base atual

### O que já existe

- o app já é `local-first` e carrega conteúdo de um vault Markdown
- `StudyStore` concentra progresso, idioma, aparência, seleção de vault e parte
  relevante da orquestração de UI
- `StudyVaultLoader` já faz parsing de conteúdo do vault para o domínio de
  checklist
- a UI atual separa `Checklist` e `Vault`, mas ainda não separa claramente
  domínio, renderização de layout, edição de vault e sessão LLM
- o repositório já exige TDD explícito e separa testes unitários de integração
- a documentação já prevê `Antigravity session hub`, vault remoto seguro,
  `browserSignIn`, `fileSync`, `versionSync` e prototipação Figma como gate

### Limites do desenho atual

- o modelo ainda é específico para um programa de estudo hardcoded, não para uma
  trilha genérica
- a renderização da área principal não nasce de um contrato `JSON -> SwiftUI`
- não existe camada dedicada para schema validation de `JSON` e `YAML`
- não existe costura explícita para contexto sandboxado da sessão ativa
- não existe bridge para `EventKit` e `Reminders`
- a UI de sessão planejada ainda não tem design tokens nem linguagem visual
  própria para fluxos tipo `Claude.app`
- o vault atual ainda não possui `tags` nem metadata suficiente para rastrear
  origem documental, arquivos relacionados e expansões futuras

## Decisão de arquitetura

### Produto-alvo

O app passa a ter três superfícies coordenadas, mas semanticamente separadas:

1. `Checklist Workspace`
2. `Vault Workspace`
3. `Assistant Session Hub`

### Regra estrutural

O `Checklist Workspace` deixa de ser uma view montada diretamente a partir do
modelo atual e passa a ser uma superfície somente leitura, gerada por um motor
de layout cujo contrato canônico nasce do vault:

- layout estrutural em `JSON`
- conteúdo textual e tokens de apresentação em `YAML`
- notas e documentos relacionais em `Markdown`

### Regra de edição

- edição documental e de nota: permitida no `Vault Workspace`
- edição estrutural da trilha: somente via sessão LLM
- escopo de contexto da LLM: apenas a sessão ativa, nunca o vault inteiro

## Fronteiras propostas

### Opção recomendada

Fazer a refatoração em duas etapas:

1. criar fronteiras lógicas novas dentro do target atual
2. extrair para múltiplos targets SwiftPM depois que testes e contratos
   estabilizarem

Isso reduz risco porque o pacote atual ainda é pequeno, mas já existe bastante
acoplamento entre store, loader e UI.

### Pacotes lógicos propostos

#### `StudyDomain`

Responsabilidade:

- contratos estáveis de domínio, independentes de SwiftUI e de plataforma

Tipos novos previstos:

- `StudyTrail`
- `TrailSession`
- `TrailNode`
- `SessionNote`
- `VaultSource`
- `VaultScope`
- `LLMSessionContext`
- `ReminderTask`
- `SessionAlarm`
- `WorkspaceLayoutSpec`
- `WorkspaceStyleCatalog`
- `SessionPermissionProfile`
- `ProviderSession`
- `DocumentSourceNode`
- `DocumentExpansion`

#### `VaultCore`

Responsabilidade:

- acesso ao vault
- enumeração de arquivos
- parse de documentos
- escrita segura
- bookmarks e escopo de acesso

Protocols principais:

- `VaultRepository`
- `VaultDocumentRepository`
- `VaultSourceResolver`
- `SafeFileWriting`
- `SecurityScopedAccessControlling`

Managers e serviços:

- `VaultManager`
- `VaultBookmarkManager`
- `VaultScopeManager`
- `MarkdownDocumentManager`
- `MarkdownMetadataIndex`
- `SafeWriteManager`
- `VaultRelationshipIndex`

#### `WorkspaceRenderer`

Responsabilidade:

- transformar `JSON` e `YAML` do vault em uma árvore de renderização neutra
- validar schema e resolver conteúdo Markdown antes da camada SwiftUI

Protocols principais:

- `WorkspaceLayoutRepository`
- `WorkspaceStyleRepository`
- `LayoutSchemaValidating`
- `StyleSchemaValidating`
- `WorkspaceRendering`

Managers e serviços:

- `JSONLayoutDecoder`
- `YAMLStyleCatalogDecoder`
- `LayoutSchemaValidator`
- `StyleCatalogValidator`
- `WorkspaceCompositionEngine`
- `MarkdownTokenResolver`
- `ReadOnlyWorkspaceViewFactory`

Modelos de renderização:

- `LayoutNode`
- `LayoutSection`
- `LayoutComponent`
- `LayoutBindingKey`
- `MarkdownContentToken`
- `StyleTokenSet`

#### `SessionOrchestration`

Responsabilidade:

- sessão ativa
- roteamento da LLM
- recorte de contexto
- ampliação temática
- mutações estruturais autorizadas

Protocols principais:

- `LLMSessionGateway`
- `SessionContextProviding`
- `TrailMutationPlanning`
- `SessionScopedPromptBuilding`
- `SessionAuditLogging`

Managers e serviços:

- `SessionScopeManager`
- `ActiveSessionContextProvider`
- `TrailMutationManager`
- `TopicExpansionManager`
- `SessionPromptBuilder`
- `SessionAuditManager`

Regras de segurança nesta fronteira:

- só lê arquivos ligados à sessão ativa
- não monta prompt com vault inteiro
- toda mutação estrutural gera proposta versionável antes de persistir

#### `AppleIntegrations`

Responsabilidade:

- adaptação para APIs nativas Apple

Protocols principais:

- `ReminderSyncing`
- `CalendarScheduling`
- `AlarmScheduling`
- `FileCoordinationControlling`

Managers e serviços:

- `EventKitPermissionManager`
- `ReminderSyncManager`
- `CalendarSyncManager`
- `SessionAlarmScheduler`
- `FileCoordinatorManager`

#### `AppFeatures`

Responsabilidade:

- composição de cenas, stores e view models
- sem parse de schema e sem lógica de filesystem

Scenes previstas:

- `ChecklistWorkspaceScene`
- `VaultWorkspaceScene`
- `AssistantSessionScene`
- `VaultSelectionFlow`
- `SessionProviderFlow`

Stores e view models previstos:

- `ChecklistWorkspaceStore`
- `VaultWorkspaceStore`
- `AssistantSessionStore`
- `WorkspaceToolbarStore`
- `SessionMenuStore`

#### `DesignSystem`

Responsabilidade:

- tokens visuais compartilhados
- estados de sessão, checklist e vault
- estilos por provedor sem quebrar a linguagem única do produto

Artefatos previstos:

- `AppColorTokens`
- `AppSpacingTokens`
- `AppTypographyTokens`
- `SessionStatusStyleTokens`
- `ProviderAccentTokens`

## Arquitetura do motor `JSON -> SwiftUI`

### Regra principal

Nenhuma nova view de workspace deve ler `JSON` ou `YAML` diretamente.

O pipeline deve ser:

1. `VaultRepository` resolve a fonte ativa
2. `JSONLayoutDecoder` decodifica a especificação estrutural
3. `LayoutSchemaValidator` valida shape, tipos e bindings
4. `YAMLStyleCatalogDecoder` carrega tokens e conteúdo localizado
5. `StyleCatalogValidator` valida chaves obrigatórias e consistência
6. `WorkspaceCompositionEngine` resolve a árvore final de renderização
7. `ChecklistWorkspaceStore` expõe `ReadOnlyWorkspaceViewState`
8. `ReadOnlyWorkspaceViewFactory` monta componentes SwiftUI puros

### Estrutura de vault recomendada

```text
Vault/
├── Trails/
│   └── <trail-id>/
│       ├── trail.json
│       ├── session.md
│       ├── nodes/
│       │   └── <node-id>.md
│       ├── notes/
│       │   └── <note-id>.md
│       ├── layout/
│       │   ├── workspace.json
│       │   └── assistant-session.json
│       └── styles/
│           ├── workspace.pt-BR.yml
│           ├── workspace.en.yml
│           ├── session.pt-BR.yml
│           └── session.en.yml
├── Shared/
│   ├── reminders.yml
│   └── providers.yml
└── VaultConfig/
    └── vault.yml
```

### Evolução do contrato Markdown

O checklist Apple atual deve sair do formato semanal linear e passar a ser uma
trilha baseada na árvore documental do produto e em fontes auxiliares.

Para isso, os arquivos Markdown do vault precisam carregar metadata relacional
parseável, em vez de apenas texto e referências web.

Campos planejados para a próxima evolução:

- `tags`
- `source_tree`
- `source_nodes`
- `related_files`
- `auxiliary_sources`
- `expansion_of`
- `activities`

Referência de auditoria:

- `docs/reference/markdown-linking-audit.md`

### Regras desse motor

- o `JSON` descreve hierarquia, slots e bindings
- o `YAML` descreve texto, labels, estilo e variantes localizadas
- o Markdown continua como fonte do conteúdo longo e notas relacionais
- o workspace ativo nunca fica editável por texto livre
- o renderer consome estado pronto; ele não decide regras de negócio

## Sessão ativa e privacidade

### Recorte obrigatório

Toda chamada para a camada LLM deve receber apenas:

- identificador da sessão ativa
- nó ativo ou seleção ativa
- notas explicitamente relacionadas à sessão
- metadata operacional mínima

Não pode receber por padrão:

- vault inteiro
- notas privadas não relacionadas
- árvore completa de arquivos
- documentos fora do `VaultScope` da sessão

### Managers necessários

- `SessionScopeManager`
  - resolve quais arquivos entram no contexto
- `ActiveSessionContextProvider`
  - monta o recorte mínimo
- `SessionPromptBuilder`
  - gera prompt por intenção: planejar, expandir tema, revisar, reorganizar
- `SessionAuditManager`
  - registra o que foi pedido, o que foi lido e o que foi mutado

## EventKit, Reminders e alarmes

### Regra funcional

Cada sessão ativa pode produzir:

- tarefas em `Reminders`
- espelhamento de agenda no `Calendar`
- alarmes de início e término

### Fluxo proposto

1. `ChecklistWorkspaceStore` gera uma projeção de tarefas da sessão
2. `ReminderSyncManager` traduz isso para entidades de `EventKit`
3. `CalendarSyncManager` agenda eventos quando a sessão exigir bloco temporal
4. `SessionAlarmScheduler` anexa alarmes de início e término
5. `EventKitPermissionManager` centraliza runtime permission e tratamento de
   negação

### Regras de robustez

- sem crash quando permissão for negada
- sem assumir que o usuário quer calendário e lembretes no primeiro uso
- ids externos devem ser persistidos para re-sync idempotente

## Padrões visuais e estilização da sessão `Claude.app`

### Direção

A sessão de assistente não deve parecer console genérico nem cópia literal de
Codex/Claude. Ela deve absorver um padrão de sessão mais calmo, editorial e
orientado a tarefa, compatível com o restante do produto.

### Padrões a incorporar

- cabeçalho de sessão com estado claro de provedor, permissão e sync
- área principal orientada a contexto atual, não a feed infinito
- blocos de raciocínio, diff, plano e ação com tipografia e densidade próprias
- badges discretos para `readOnly`, `planOnly`, `reviewOnly` e
  `sandboxedExecution`
- separação visual entre:
  - contexto da trilha
  - proposta da I.A.
  - ação aprovada
  - resultado persistido
- uso consistente de monoespaçada apenas em artefatos técnicos, nunca como
  linguagem visual dominante da tela

### Tokens novos necessários

- `SessionChromeTokens`
- `ProviderAccentTokens`
- `PermissionBadgeTokens`
- `SyncStatusTokens`
- `CodeArtifactTokens`
- `EditorialSurfaceTokens`

### Gate de design

Antes de implementar a `AssistantSessionScene`, prototipar no Figma:

- `SessionMenu`
- `Claude.app style session detail`
- `Provider switcher`
- `Permission profile card`
- `Sync and history rail`
- `Expanded topic proposal flow`

## Estratégia TDD

### Ordem obrigatória

Cada fatia nasce assim:

1. teste unitário ou de integração falhando
2. implementação mínima
3. refactor com testes verdes
4. atualização documental

### Suites novas previstas

#### Unit

- `WorkspaceLayoutDecoderTests`
- `WorkspaceLayoutSchemaValidatorTests`
- `WorkspaceStyleCatalogDecoderTests`
- `WorkspaceCompositionEngineTests`
- `SessionScopeManagerTests`
- `SessionPromptBuilderTests`
- `ReminderProjectionMapperTests`

#### Integration

- `VaultManagerFlowTests`
- `SafeWriteManagerTests`
- `ChecklistWorkspaceStoreTests`
- `AssistantSessionStoreTests`
- `ReminderSyncManagerTests`
- `CalendarSyncManagerTests`
- `VaultScopeSecurityTests`

### Casos críticos a cobrir

- `JSON` inválido não derruba o app
- `YAML` inválido entra em estado de erro explícito
- escrita segura não sobrescreve silenciosamente conteúdo corrompido
- mudança estrutural proposta pela LLM gera diff auditável antes do save
- contexto enviado ao gateway da LLM respeita o escopo da sessão
- sync com `EventKit` trata permissão negada e reexecução idempotente

## Fases de implementação

### Marco de infraestrutura. Migrar colaboração para GitLab

Antes do próximo marco de conteúdo, concluir a migração operacional do
repositório para `GitLab` seguindo o plano dedicado.

Referência:

- `docs/product/git-migration-plan.md`

### Fase 0. Gate de prototipação e contrato

- consolidar protótipo Figma para checklist editorial, vault e sessão
- fechar padrões de estilização da sessão `Claude.app`
- revisar contrato do vault genérico
- congelar estrutura inicial de `JSON`, `YAML` e `Markdown`

### Fase 1. Extrair domínio e vault core

- introduzir novos contratos de domínio
- extrair `VaultCore`
- manter compatibilidade com vault atual enquanto a migração acontece
- cobrir seleção de vault, escopo e safe writes

### Fase 2. Construir o motor de layout

- adicionar `WorkspaceRenderer`
- introduzir validação de schema
- mover a composição do workspace para estado renderizado
- manter workspace em `read-only`

### Fase 3. Introduzir sessão ativa e sandbox de contexto

- criar `SessionOrchestration`
- suportar ampliar tema e reorganizar trilha via proposta
- persistir alterações estruturais apenas por fluxo aprovado

### Fase 4. Integrar EventKit

- bridge para lembretes, calendário e alarmes
- ids externos persistidos
- estados de permissão e erro visíveis

### Fase 5. Limpar UI e migrar cenas

- separar `ChecklistWorkspaceScene`, `VaultWorkspaceScene` e
  `AssistantSessionScene`
- reduzir `StudyStore` e aposentar responsabilidades que migrarem para stores
  novas
- estabilizar internacionalização e tokens de design

### Próximo marco após a migração Git

Refatorar o checklist Apple atual para um formato de estudo mais instrutivo,
direcional e centrado na árvore documental.

Objetivos desse marco:

- ancorar cada bloco de estudo em nós explícitos da documentação e em fontes
  auxiliares
- centralizar atividades e entregáveis por unidade de estudo, não por rolagem
  linear extensa
- introduzir expansões de conteúdo para detalhamento progressivo
- evitar repetição textual no detalhamento diário
- persistir `tags` e referências de arquivo para futura visualização relacional
  no app

## Ordem recomendada de arquivos a nascer

### Primeiro bloco

- `Sources/AppleStudyChecklist/Domain/`
- `Sources/AppleStudyChecklist/VaultCore/`
- `Sources/AppleStudyChecklist/WorkspaceRenderer/`
- `Tests/AppleStudyChecklistTests/Unit/WorkspaceLayoutDecoderTests.swift`
- `Tests/AppleStudyChecklistTests/Unit/WorkspaceStyleCatalogDecoderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultManagerFlowTests.swift`

### Segundo bloco

- `Sources/AppleStudyChecklist/SessionOrchestration/`
- `Tests/AppleStudyChecklistTests/Unit/SessionScopeManagerTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/AssistantSessionStoreTests.swift`

### Terceiro bloco

- `Sources/AppleStudyChecklist/AppleIntegrations/`
- `Tests/AppleStudyChecklistTests/Integration/ReminderSyncManagerTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/CalendarSyncManagerTests.swift`

### Só depois

- novas views em `AppFeatures`
- migração da tela principal para o renderer novo

## Interoperabilidade de MCPs e ferramentas da sessão

### MCPs e plugins confirmados nesta sessão

- `MCP_DOCKER`
  - apoio principal para filesystem local, busca estrutural, `git`, diffs,
    automação de browser e inspeção de artefatos
- `notion`
  - útil para documentação estruturada, pesquisa interna e captura de decisão
- `openaiDeveloperDocs`
  - disponível por ferramentas específicas; útil para validar integração futura
    com OpenAI sem depender de memória do modelo
- `GitHub` plugin
  - revisão de PR, comentários e conferência de feedback
- `Figma` plugin
  - design context, design system rules e code connect para o handoff de
    prototipação

### Seleção recomendada para esta refatoração

- revisão e conferência de código:
  - `MCP_DOCKER`
  - `GitHub`
- qualidade de código e métricas estruturais:
  - `MCP_DOCKER` com busca AST, diff e suites de teste
- apoio ao desenvolvimento:
  - `MCP_DOCKER`
  - `openaiDeveloperDocs`
- arquitetura, versionamento e organização:
  - `MCP_DOCKER`
  - `notion` quando houver necessidade de consolidar documentação externa ao repo
- prototipação e design system:
  - `Figma`

### Regra de interoperabilidade

- MCPs não substituem leitura e edição básica do vault
- o vault continua local-first e filesystem-first
- Figma entra como gate de prototipação e alinhamento visual, não como fonte de
  verdade do conteúdo
- integrações de revisão e docs servem à engenharia, mas não devem ampliar o
  escopo de contexto da sessão ativa no runtime do app

## Critérios para começar a codar

- aprovação explícita deste plano
- confirmação de onde ficará o novo vault de trilhas genéricas
- confirmação se a refatoração começa preservando o target único ou já com
  extração para múltiplos targets
- confirmação do gate Figma para a sessão `Claude.app`

## Próxima ação após aprovação

Ao receber `Ok`, a primeira fatia deve ser:

1. criar `WorkspaceLayoutDecoderTests`
2. criar `WorkspaceStyleCatalogDecoderTests`
3. criar contratos mínimos de `WorkspaceLayoutSpec` e `WorkspaceStyleCatalog`
4. só então iniciar a implementação do motor `JSON -> SwiftUI`
