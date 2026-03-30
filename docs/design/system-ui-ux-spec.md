# Especificação de UI e UX do Sistema

## Navegação

- Primary shell:
  - tab-based separation between `Checklist` and `Vault`
- Checklist:
  - split navigation on desktop and large screens
  - compact push navigation later on smaller devices
- Vault:
  - document list on the leading side
  - viewer or editor in the detail area

## Direção visual da próxima versão

Referência de linguagem: Apple Music.

Isso não significa copiar a interface. Significa absorver padrões de produto que funcionam bem no ecossistema Apple:

- hierarquia editorial forte
- foco evidente no contexto atual
- navegação rasa e previsível
- superfícies amplas com pouco ruído
- toolbar discreta e conteúdo dominante
- sensação de app nativo, não de ferramenta genérica

## Etapa prévia de prototipação

Esta entrega deve passar por uma etapa prévia de prototipação antes do TDD.

Esse gate vale especialmente para:

- menu de sessões
- `browserSignIn`
- estados de sync
- histórico e revisão
- sessões paralelas

O objetivo é validar hierarquia, ritmo visual e previsibilidade de navegação antes de cristalizar contratos e stores.

## Tradução dessa referência para o produto

### Checklist

- A semana atual deve virar a peça principal da tela
- O cabeçalho da semana precisa ser mais forte que a lista de tarefas
- Resumo, objetivo, entregável e referências devem parecer parte de uma experiência editorial
- O bloco ativo precisa ser reconhecível à primeira vista

### Vault

- A biblioteca de arquivos deve parecer coleção organizada, não browser cru de filesystem
- O detalhe do arquivo precisa priorizar leitura antes de edição
- Ações de origem, sync e save devem existir, mas sem disputar atenção com o conteúdo
- Em iPhone, a pilha de navegação deve parecer consumo de biblioteca, não painel técnico de desktop comprimido
- A estrutura visual deve absorver a utilidade do `FrankMD`, mas com linguagem
  nativa e escalável para futuras plataformas, não com aparência de web app

### Sessões

- O menu de sessões `Antigravity` deve parecer um centro de controle calmo, não um terminal ruidoso
- A troca entre `Codex`, `Claude` e `Gemini` precisa ser clara e persistida
- Permissões, estado de sandbox e origem de memória compartilhada devem ser visíveis antes da sessão começar
- Histórico, sync e estado de autenticação devem parecer parte do mesmo produto do vault, não uma superfície separada

### Tema

- `light`, `dark` e `automatic` devem alterar atmosfera e legibilidade, não apenas trocar fundo e texto
- Estados de leitura longa precisam ser confortáveis em ambos os modos
- O tema deve atravessar checklist e vault como uma linguagem única

## Sistema visual

- Use Apple system typography as the baseline
- Keep hierarchy strong through spacing and sectioning before adding decoration
- Preserve a technical tool aesthetic instead of a marketing UI aesthetic
- Prefer bold section rhythm over chrome-heavy containers
- Use artwork-like emphasis for week context and content grouping
- Keep lists calm, with generous spacing and clear active state

## Estados

### Checklist

- empty week selection
- normal browsing
- progress update
- week reset

### Vault

- no workspace selected
- workspace loaded
- file selected
- save success
- save failure

### Sessões

- signed out
- provider connected
- provider unavailable
- active parallel sessions
- sync pending
- conflict detected

## Modelo de tema

- `automatic`
- `light`
- `dark`

The theme selection should live in app state and affect both checklist and vault surfaces.

## Regras de adaptação por plataforma

### macOS

- full split view is acceptable
- command-centric editing workflows are acceptable
- a superfície pode ser mais densa, mas ainda deve respeitar o modelo de
  biblioteca e documento definido para o produto

### iOS

- compact navigation must replace desktop assumptions
- file picking must not depend on `NSOpenPanel`
- toolbar density must be reduced
- the first screen should feel like a curated library or media destination
- detail views should prioritize reading flow before edit controls
- the session menu should expose provider state, permission mode, and sync status without feeling like a dev console

### visionOS

- do not ship a spatial experience just to mirror the desktop layout
- only add a dedicated visionOS surface when the interaction model adds value

### Android e Windows

- futuras plataformas devem herdar o mesmo modelo de domínio e de vault
- não devem copiar a UI Apple literalmente
- a taxonomia de informação e o comportamento de sync precisam ser os mesmos
- a apresentação pode mudar para respeitar a plataforma

## Checklist de validação de design

- Can the user tell which study context is active?
- Can the user tell whether the current workspace is editable?
- Can the user tell whether a file save succeeded or failed?
- Are reading and editing both viable in dark mode?
- Does the compact layout preserve the product model without cloning the desktop split view?
- Does the iPhone layout feel closer to an Apple media app than to a compressed desktop tool?
