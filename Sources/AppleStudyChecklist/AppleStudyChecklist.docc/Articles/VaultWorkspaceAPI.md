# API do Workspace do Vault

## Visão geral

O workspace do vault é a fronteira de feature entre o conteúdo em Markdown e a UI do app.

O contrato atual se concentra em:

- `StudyLabels`
- `VaultFileEntry`
- `VaultWorkspaceState`
- `StudyStore`
- `StudyVaultLoader`

O workspace pode ser carregado a partir de:

- the bundled vault
- a local editable copy
- an imported external folder

## Documentação relacionada do repositório

- `docs/api/vault-workspace-api.md`
- `docs/architecture/system-overview.md`
