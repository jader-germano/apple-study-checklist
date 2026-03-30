# Extração Multiplataforma Do Conceito FrankMD

- Categoria: `architecture`
- Escopo: `system`

## Propósito

Definir como extrair o conceito de produto do `FrankMD` para uma experiência
nativa multiplataforma, sem portar o web app Rails como dependência do app.

O objetivo é preservar o que faz sentido no modelo do `FrankMD`:

- vault Markdown como fonte de verdade
- organização por árvore de arquivos e pastas
- leitura, edição, preview, busca e histórico no mesmo produto
- local-first com backend opcional

Ao mesmo tempo, o produto deve nascer orientado a clientes nativos:

- iPhone
- iPad
- macOS

E deve manter abertura futura para:

- Android
- Windows

## Decisão principal

O produto não deve embutir o `FrankMD` como dependência de runtime do app.

Ele deve extrair e reusar o conceito de produto, definindo contratos
multiplataforma para:

- vault
- árvore de navegação
- leitura e preview
- edição
- busca
- histórico
- sync
- sessões com LLM

## O que extrair do FrankMD

### 1. Vault filesystem-first

- arquivos Markdown como fonte de verdade
- estrutura aninhada por pastas
- compatibilidade com roots locais e remotos autorizados

### 2. Modelo de biblioteca

- árvore de arquivos
- navegação por contexto
- sensação de biblioteca pessoal, não de banco de dados opaco

### 3. Fluxo de leitura e edição

- leitura forte
- edição explícita
- preview útil
- save visível

### 4. Segurança e resiliência

- local-first
- estados visíveis de sync
- histórico de versões
- conflito explícito

### 5. Extensibilidade

- provedores opcionais
- backend opcional
- sem transformar o produto em web app embrulhado
- companion desktop opcional quando fizer sentido para leitura, edição ou
  revisão documental

## O que não extrair

### 1. O shell web do Rails

- rotas web
- UI web como superfície canônica
- dependência do browser como interface principal

### 2. Acoplamento a backend único

- o app não deve depender do `FrankMD` estar rodando para leitura e edição
- o `FrankMD` pode existir como backend opcional, não como núcleo obrigatório
- mounts locais de companion não devem virar o mecanismo principal de sync do
  produto

### 3. UX desktop/web copiada literalmente

- menus de contexto e densidade de tela do web app não devem ser portados de
  forma cega para iPhone
- a experiência precisa parecer nativa em cada plataforma

## Camadas propostas

### Camada 1: Domain contracts

Contratos independentes de plataforma para:

- `VaultNode`
- `VaultDocument`
- `VaultSearchResult`
- `FileSyncState`
- `VersionSyncState`
- `SessionPermissionProfile`
- `ProviderSession`

Essa camada é a parte realmente reaproveitável para Apple, Android e Windows.

### Camada 2: Native platform shells

- Apple shell agora: iPhone, iPad, macOS
- Android shell depois
- Windows shell depois

Cada shell adapta navegação, input e layout, sem quebrar o mesmo modelo de
domínio.

### Camada 3: Optional backends

- `Antigravity` para auth, sessão, permissões e auditoria
- `FrankMD` como referência funcional e backend opcional de vault/search/history
- outros backends apenas se seguirem os mesmos contratos

## Operação segura do companion FrankMD

- quando usado como companion local, o `FrankMD` deve abrir um recorte curado do
  vault sempre que possível
- para consulta, o ideal é leitura em modo read-only
- o produto não deve assumir mount bruto do workspace como estratégia padrão
- wrappers locais ajudam no cleanup, mas a segurança real continua dependendo do
  escopo do mount

## Estratégia multiplataforma

## Apple first

O primeiro corte continua focado em Apple platforms:

- iPhone como prioridade de UX
- iPad como expansão de navegação e produtividade
- macOS como superfície mais densa de edição e revisão

## Android depois

Android deve herdar:

- o mesmo modelo de vault
- o mesmo modelo de sync
- o mesmo modelo de sessão
- a mesma classificação documental

Sem herdar a UI Apple literalmente.

## Windows depois

Windows deve herdar:

- a mesma semântica de vault
- o mesmo histórico/versionamento
- o mesmo broker de sessão

Sem virar um clone do web app.

## Implicações para a UI

- a UI deve se inspirar na organização e na utilidade do `FrankMD`
- a UI não deve copiar a aparência do web app
- a navegação deve parecer app nativo de biblioteca e conteúdo
- checklist, vault e sessões precisam coexistir como um só produto

## Próximos artefatos que precisam respeitar esta decisão

- `docs/architecture/system-overview.md`
- `docs/architecture/antigravity-session-hub.md`
- `docs/design/system-ui-ux-spec.md`
- `docs/product/roadmap.md`
- `docs/product/dos-and-donts.md`

## Status

- direção aprovada para arquitetura
- sem implementação ainda
