# Roadmap do Produto

- Categoria: `product`
- Escopo: `repository` e `feature`

## Estado atual

O produto já cobre o núcleo do MVP:

- programa de estudo carregado de Markdown
- fallback seguro para vault ausente, vazio ou inválido
- criação de vault editável, save local e carga direta de vault externo cobertos por testes
- escolha de idioma da interface entre `pt-BR` e `English`
- host iOS real com domínio compartilhado no pacote Swift

Rastreabilidade atual:

- código: `Sources/AppleStudyChecklist/StudyStore.swift`, `Sources/AppleStudyChecklist/StudyVaultLoader.swift`, `Sources/AppleStudyChecklist/ContentView.swift`
- testes: `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`, `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`, `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`
- docs: `docs/api/vault-workspace-api.md`, `docs/architecture/system-overview.md`

## Agora

### 1. Fechar o MVP do vault local

- Manter cobertos com testes os fluxos de criar vault editável, conectar pasta externa e salvar arquivo
- Remover lacunas entre documentação, implementação e comportamento real do workspace
- Consolidar a navegação e edição de arquivos como fluxo local-first
- Garantir que esses testes permaneçam seguros com paralelismo habilitado
- Manter este app como a linha principal de execução até fechar um ciclo útil antes de abrir o próximo produto do portfólio

Referências:

- `docs/api/vault-workspace-api.md`
- `docs/engineering/test-architecture.md`
- `docs/architecture/system-overview.md`

## Próximo

### Infra. Concluir a migração GitHub -> GitLab

- Fechar a janela curta de freeze para corte de colaboração
- Operar o fluxo principal em `GitLab`
- Fechar o cutover de remoto e o arquivamento do `GitHub`
- Recriar no destino a governança que não vier pronta do import

Referências:

- `docs/product/git-migration-plan.md`

### 1. Refatorar o checklist Apple atual para trilha guiada por documentação

- Reestruturar o checklist para nascer da árvore documental e de fontes
  auxiliares, e não apenas de uma lista semanal linear
- Centralizar atividades, saídas esperadas e links de origem em blocos mais
  instrutivos
- Introduzir expansões para reduzir rolagem excessiva no app
- Exigir metadata Markdown com `tags` e referências de arquivo para suportar
  visualização relacional futura

Referências:

- `docs/product/implementation-plan.md`
- `docs/reference/markdown-linking-audit.md`

### Fase 0. Prototipar a entrega antes da implementação

- Fechar os protótipos Figma da entrega `Antigravity + sync` antes de abrir as fatias de código
- Validar a hierarquia do menu de sessões, o estado do vault compartilhado e os estados de `fileSync` e `versionSync`
- Confirmar o comportamento das superfícies em iPhone, iPad e macOS antes do TDD
- Manter essa etapa como gate visual para features que mudem navegação, sessão, revisão ou sync

Referências:

- `docs/design/figma-prototype-brief.md`
- `docs/design/system-ui-ux-spec.md`
- `docs/architecture/antigravity-session-hub.md`

### 2. Tornar a experiência de edição consistente no app

- Completar a internacionalização dos textos restantes da UI
- Estruturar uma visualização de arquivos inspirada no FrankMD, mas nativa ao padrão iOS
- Manter tema `light`, `dark` e `automatic` como preferência persistida
- Abrir a fase 1 de acesso seguro ao vault remoto do container no iPhone, inicialmente em modo leitura
- Modelar a fundação do menu de sessões `Antigravity`, com login via browser, permissões explícitas e sync orientado a arquivo/versão

Referências:

- `docs/design/system-ui-ux-spec.md`
- `docs/design/figma-prototype-brief.md`
- `docs/product/dos-and-donts.md`
- `docs/architecture/secure-container-access.md`
- `docs/architecture/antigravity-session-hub.md`
- `docs/api/antigravity-session-api.md`
- `docs/architecture/frankmd-multiplatform-extraction.md`

## Depois

### 3. Evoluir o produto sem romper o modelo local-first

- Expandir o bridge seguro entre o vault local e fontes MCP opcionais
- Preparar superfícies adicionais para iPad e macOS sem bifurcar o domínio
- Versionar mudanças de conteúdo e documentação com rastreabilidade por categoria e escopo
- Conectar histórico, planejamento e execução assistida por LLM em uma sessão móvel unificada
- Extrair contratos de vault, sync e sessão de modo que o conceito do FrankMD
  possa viver em clientes nativos futuros além de Apple
- Planejar a expansão futura para Android e Windows sem transformar o app em
  réplica do web app

## Sequência Entre Produtos

- Este app permanece como produto atual prioritário
- Estratégia de entrega entre produtos:
  - mobile primeiro
  - depois desktop/PC
  - depois web
- O portfólio entra como próximo produto somente depois do ciclo principal do
  checklist

Referências:

- `docs/architecture/system-overview.md`
- `docs/reference/external-standards.md`
- `docs/engineering/project-patterns.md`
- `docs/architecture/frankmd-multiplatform-extraction.md`

## Regra de atualização

Ao iniciar uma nova fatia:

1. ajustar este roadmap se a prioridade do produto mudou
2. se a fatia mudar navegação, sessão, revisão ou sync, fechar protótipo antes da implementação
3. declarar entregáveis da sessão e abrir o pacote de evidências correspondente no hub
4. atualizar o documento de produto ou arquitetura mais próximo
5. atualizar testes e API docs na mesma fatia
6. registrar a mudança no DocC quando houver impacto no uso por desenvolvedores
7. fechar a sessão com relatório, link de Figma e GIFs de macOS e iOS antes de marcar a feature como concluída
