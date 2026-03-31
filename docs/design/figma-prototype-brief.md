# Brief de Protótipo Figma

## Status

Este repositório está pronto para um fluxo de implementação guiado por Figma.

Este documento é um brief de handoff de design para o repositório, não um
registro do estado transitório de uma sessão específica do Codex.

Quando a sessão entrar em uma `feature`, o frame ou arquivo usado aqui deve ser
referenciado no relatório operacional da sessão, junto com as evidências de
funcionamento em macOS e iOS, no hub em
`reports/sessions/<feature-id>/<yyyy-mm-dd-session>/`.

A validação operacional do tooling deve acontecer em cada sessão de trabalho,
antes de depender de leitura de contexto, escrita de design ou handoff de
componentes.

Pré-condições mínimas para a próxima sessão de design:

- um frame ou arquivo real do Figma para validar leitura de contexto
- uma sessão com escrita de design habilitada para prototipar telas nativas do
  app
- confirmação do workflow de handoff que será usado naquela sessão

## Validação atual

Validação funcional já confirmada no código atual:

- fallback para vault ausente, vazio ou inválido
- criação da cópia local editável do vault
- persistência de edição em arquivo Markdown do vault
- carga direta de pasta externa para validação do fluxo de workspace
- escolha de idioma e preferências persistidas no shell atual

Validação ainda pendente no protótipo visual:

- frame ou arquivo real do Figma para leitura e escrita
- navegação do `Antigravity` com `SessionMenu` e `BrowserSignIn`
- estados visuais de `fileSync`, `versionSync`, conflito e sessões paralelas
- composição comparada entre iPhone, iPad e macOS

## Referência visual

A próxima versão deve se inspirar na linguagem do Apple Music.

Princípios que devem ser levados para o protótipo:

- destaque forte para o contexto atual
- ritmo editorial nas seções
- conteúdo como protagonista
- navegação simples e previsível
- sensação de app nativo Apple em vez de ferramenta utilitária

## Fluxo Figma necessário

O fluxo pretendido segue a skill local `figma-implement-design`:

1. select a frame or provide a Figma URL
2. fetch design context
3. capture a screenshot
4. map the result into project conventions
5. validate code against the design source

## Etapa prévia desta entrega

Antes das quatro fases de implementação, esta entrega precisa fechar uma etapa prévia de prototipação.

Objetivo dessa etapa:

- validar a IA de navegação do menu `Antigravity`
- validar a relação entre vault, sessão, histórico e sync no mesmo produto
- confirmar a composição das telas em iPhone, iPad e macOS
- reduzir risco de misturar modelagem de sessão com execução de código cedo demais

Saídas mínimas esperadas:

- fluxo do `browserSignIn`
- menu de sessão com `Codex`, `Claude` e `Gemini`
- estado de memória compartilhada do vault
- estados de `fileSync` e `versionSync`
- histórico, conflito e sessões paralelas

## Versões para prototipar

### V1. MVP local atual

- Checklist workspace
- Vault local workspace
- estados de fallback para vault ausente, vazio ou inválido
- `pt-BR` and `English` interface choice

### V2. Próxima versão editorial

- `Week hero` como superfície dominante
- ritmo mais calmo e editorial no checklist
- navegação do vault com sensação de coleção
- `light`, `dark`, and `automatic` as product-level theme states

### V3. Vault remoto seguro no iPhone

- leitura remota autenticada do vault
- estado de origem mais claro no workspace do vault
- feedback remoto sem quebrar o modelo `local-first`

### V4. Refinamento cross-platform

- iPhone compact flow
- iPad regular-width composition
- macOS denser editing shell without changing the shared domain model

### Gate antes do código

A implementação da entrega deve começar só depois de existir um protótipo navegável, ainda que de baixa fidelidade, para:

- `SessionMenu`
- `BrowserSignIn`
- `RemoteVault`
- `History and Review`
- `Sync Status`

No estado atual, esse gate permanece aberto para as superfícies de sessão e
sync, mas o workspace local do vault já está funcionalmente validado no código.

## Telas para prototipar

### 1. Workspace de checklist

- Week list
- Week summary
- Daily checklist cards
- References, glossary, and study guide blocks
- Hero da semana atual com tratamento visual dominante
- Organização das seções como biblioteca editorial

### 2. Workspace do vault

- Vault source controls
- Markdown file list
- Editor and preview surface
- Save and error feedback states
- Biblioteca de arquivos com cara de coleção navegável
- Leitura do arquivo priorizada antes do modo de edição

### 3. Adaptações cross-platform

- iPad regular-width layout
- iPhone compact navigation flow
- visionOS concept only after the shared app flows are stable

### 4. Menu de sessões Antigravity

- Browser sign-in entry
- Provider activation for `Codex`, `Claude`, and `Gemini`
- Permission profile and sandbox reference
- Shared-memory vault reference
- File sync, version sync, and history states
- Active parallel sessions with clear ownership

## Componentes para desenhar

- Navigation shell
- Week row
- Week detail header
- Week hero
- Daily task card
- Markdown file row
- Editor header
- Save feedback banner
- Appearance selector
- Session provider row
- Permission profile card
- Sync status badge
- Parallel session list row

## Restrições de design

- Respeitar a arquitetura `SwiftUI-first` atual
- Reusar padrões do sistema Apple quando fizer sentido
- Evitar criar uma segunda linguagem de produto só para o vault
- Manter o app como `local-first`, mesmo quando conteúdo apoiado por MCP entrar
  depois
- Não clonar o Apple Music literalmente; adaptar sua hierarquia e calma para um
  produto de estudo

## Viabilidade atual de prototipação

Hoje, a geração dos protótipos do roadmap é viável em dois níveis:

- imediatamente: mapa de fluxo, navegação e estados em FigJam
- com pré-condição adicional: telas reais de app em arquivo Figma com contexto
  de leitura e escrita validado

Em outras palavras:

- o brief já está suficientemente maduro para prototipação
- a parte que ainda depende de validação de tooling é a escrita canônica das
  telas de app no Figma Design
