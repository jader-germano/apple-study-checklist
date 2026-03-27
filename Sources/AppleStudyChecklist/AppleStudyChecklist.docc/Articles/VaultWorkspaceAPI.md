# Vault Workspace API

## Overview

The vault workspace is the feature boundary between markdown content and the app UI.

The current contract is centered on:

- `StudyLabels`
- `VaultFileEntry`
- `VaultWorkspaceState`
- `StudyStore`
- `StudyVaultLoader`

The workspace can be loaded from:

- the bundled vault
- a local editable copy
- an imported external folder

## Related repository docs

- `docs/api/vault-workspace-api.md`
- `docs/architecture/system-overview.md`
