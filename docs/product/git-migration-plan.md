# Plano de Migração GitHub -> GitLab

- Categoria: `product`
- Escopo: `repository`

## Objetivo

Migrar a colaboração primária do repositório de `GitHub` para `GitLab`
preservando histórico Git, governança de branch e um ponto claro de corte para a
equipe.

## Estado atual

Estado validado em `2026-03-29` e `2026-03-30`:

- remoto atual local: `origin -> https://github.com/jader-germano/apple-study-checklist.git`
- projeto criado no GitLab: `https://gitlab.com/jader-germano/apple-study-checklist`
- slug remoto já está no padrão `lowercase-with-hyphens`
- `glab` instalado e autenticado como `jader-germano`
- importação por `Repository by URL` concluída com sucesso

Resultado real da importação:

- branches importadas: `main` e `feature/vault-session-refactor`
- projeto público criado em `GitLab`
- `main` disponível e protegida
- merge requests, issues e labels não vieram pelo caminho de importação por URL

## Estratégia adotada

### Caminho executado

Foi usado o fluxo `Repository by URL` porque:

- o repositório GitHub é público
- o ambiente ficou pronto para autenticar no GitLab
- o importador GitHub completo exigiria credencial válida do lado GitHub, que
  não estava operacional neste ambiente

### Limite do caminho adotado

Esse caminho traz o repositório Git e as refs, mas não importa automaticamente:

- merge requests
- issues
- labels
- comentários históricos de revisão

## Execução em 5 passos

### 1. Congelar merge por uma janela curta

Objetivo:

- impedir divergência entre GitHub e GitLab durante o cutover

Status:

- preparado
- ainda depende de comunicação operacional da equipe

### 2. Importar o repositório no GitLab

Objetivo:

- criar o projeto de destino e trazer histórico Git

Execução:

- `glab` instalado localmente
- autenticação `glab` concluída
- namespace validado: `jader-germano`
- projeto criado no GitLab com `import_url` público do GitHub

Status:

- concluído

### 3. Validar manualmente o importado

Checklist fechado neste ambiente:

- `default_branch`: `main`
- projeto não está vazio
- branches visíveis: `main` e `feature/vault-session-refactor`
- tags locais: nenhuma
- tags no GitLab: nenhuma
- `merge_requests_enabled`: `true`
- `issues_enabled`: `true`
- `wiki_enabled`: `true`
- `import_status`: `finished`

Lacuna confirmada:

- `0` merge requests importadas
- `0` issues importadas
- `0` labels importadas

Status:

- concluído com ressalva

### 4. Recriar a governança que não vier pronta

Objetivo:

- restabelecer o contrato operacional no GitLab

Estado já observado:

- `main` já veio protegida
- projeto está público
- `remove_source_branch_after_merge` já está `true`

Pendências para a próxima fatia:

- revisar approval rules conforme o plano gratuito do GitLab
- recriar labels úteis de fluxo se forem necessárias
- revisar se `only_allow_merge_if_pipeline_succeeds` deve ser ativado quando a
  CI do GitLab existir

Status:

- parcialmente concluído

### 5. Trocar o remoto padrão e arquivar o GitHub

Objetivo:

- concluir o cutover oficial

Pendências reais:

- `origin` já aponta para o GitLab no clone local
- o GitHub foi preservado como remoto secundário `github`
- arquivar o repositório no GitHub quando o time confirmar que o fluxo principal
  já migrou

Status:

- parcialmente concluído

## Próximo marco após a migração

Assim que o cutover operacional fechar, abrir a refatoração do checklist Apple
atual para uma trilha instrutiva guiada pela árvore documental e por fontes
auxiliares.

Esse marco deve:

- ancorar cada bloco em nós explícitos da documentação
- centralizar atividades e saídas por unidade de estudo
- introduzir expansões para reduzir rolagem contínua
- exigir `tags` e referências de arquivo no Markdown para futura visualização no
  app

Referências internas:

- `docs/product/implementation-plan.md`
- `docs/product/roadmap.md`
- `docs/reference/markdown-linking-audit.md`

## Referências externas

- GitLab Docs: `https://docs.gitlab.com/user/project/import/repo_by_url/`
- GitLab Docs: `https://docs.gitlab.com/api/protected_branches/`
- GitHub Docs: `https://docs.github.com/en/enterprise-server@3.15/repositories/archiving-a-github-repository/archiving-repositories`
