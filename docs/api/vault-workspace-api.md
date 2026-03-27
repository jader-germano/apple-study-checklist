# API do Workspace do Vault

- Categoria: `api`
- Escopo: `feature`

## Propósito

Este documento descreve o contrato atual, voltado a quem desenvolve, do workspace do vault.

Não é uma API de rede. É o contrato interno entre conteúdo Markdown, carregamento do workspace e UI.

## Tipos principais

### StudyLabels

Definido em `Sources/AppleStudyChecklist/Models.swift`.

Controla os rótulos visíveis ao usuário carregados do metadata Markdown ou dos valores padrão.

### VaultFileEntry

Definido em `Sources/AppleStudyChecklist/Models.swift`.

Representa um arquivo Markdown descoberto no workspace atual.

### VaultWorkspaceState

Definido em `Sources/AppleStudyChecklist/Models.swift`.

Estados suportados:

- `ready`
- `empty`
- `setupRequired`

### StudyStore

Definido em `Sources/AppleStudyChecklist/StudyStore.swift`.

Responsabilidades voltadas à UI:

- carregar a fonte ativa do vault
- expor `vaultFiles`, `selectedFile`, `selectedFileContent`
- expor `sourceDescription`, `isVaultEditable`, `vaultState`
- persistir progresso, aparência e idioma

### StudyVaultLoader

Definido em `Sources/AppleStudyChecklist/StudyVaultLoader.swift`.

Responsabilidades:

- ler `Config/app-config.md`
- enumerar arquivos Markdown
- mapear `Weeks/*.md` para `WeekPlan`
- aplicar fallback e override por idioma com chaves `*_en`
- montar `StudyWorkspace`

### AppLanguage

Definido em `Sources/AppleStudyChecklist/Models.swift`.

Representa o idioma da interface e dos campos localizáveis do vault.

Valores atuais:

- `pt-BR`
- `en`

## Modos de origem

O workspace atual pode vir de:

- vault embutido
- cópia local editável em Application Support
- pasta externa importada pelo seletor

## Rastreabilidade

Código relacionado:

- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`
- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`
- `Sources/AppleStudyChecklist/Resources/Vault/Config/app-config.md`

Testes relacionados:

- `Tests/AppleStudyChecklistTests/Unit/StudyVaultLoaderTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/StudyStorePersistenceTests.swift`
- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`

DocC relacionado:

- `Sources/AppleStudyChecklist/AppleStudyChecklist.docc/Articles/VaultWorkspaceAPI.md`
