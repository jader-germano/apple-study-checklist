# Auditoria de Linkagem e Metadata Markdown

- Categoria: `reference`
- Escopo: `repository`

## Objetivo

Registrar o estado atual dos arquivos Markdown usados pelo produto e definir o
gap até um modelo de metadata que permita visualização relacional no app.

## Escopo auditado

- `Sources/AppleStudyChecklist/Resources/Vault/**/*.md`
- `docs/**/*.md`

Data da auditoria:

- `2026-03-29`

## Resultado atual

### Vault do app

Contagem validada no estado atual:

- `13` arquivos Markdown no vault
- `13` arquivos com front matter
- `12` arquivos com campo `references`
- `12` arquivos com campo `glossary`
- `0` arquivos com campo `tags`
- `0` arquivos com campos de linkagem como `file_reference`, `source_path`,
  `related_files`, `source_nodes` ou equivalentes

Leitura do resultado:

- o vault já é consistente como fonte de checklist semanal
- ele já aponta para referências externas
- ele ainda não modela a relação entre arquivos, nós de documentação e
  expansões temáticas

### Documentação do repositório

Contagem validada no estado atual:

- `26` arquivos Markdown em `docs/`
- `0` com front matter
- `0` com campo `tags`
- `0` com campos de linkagem explícita entre arquivos

Leitura do resultado:

- a documentação atual é navegável por estrutura de pastas e hyperlinks no
  corpo do texto
- ela ainda não expõe um contrato parseável de tags e referências internas

## Diagnóstico

O checklist atual consegue exibir conteúdo e referências web, mas não consegue
ser lido como um grafo documental.

Isso limita:

- visualização futura de origem de conteúdo no app
- navegação por tópicos, árvore e dependências
- renderização de expansões contextuais sem duplicar texto
- agrupamento de atividades por fonte principal e fontes auxiliares

## Contrato recomendado para o vault

Para os arquivos Markdown que alimentarem checklist, sessão e notas, adotar o
seguinte conjunto mínimo de campos:

- `tags`
- `source_tree`
- `source_nodes`
- `related_files`
- `auxiliary_sources`
- `expansion_of`
- `activities`

Exemplo proposto:

```md
---
title: Darwin, filesystem e app bundles
tags: apple-platform | filesystem | bundle
source_tree: docs-tree/apple-platform-foundations
source_nodes: docs/reference/external-standards.md | docs/architecture/system-overview.md
related_files: Weeks/02-processos-threads.md | Notes/filesystem-lab.md
auxiliary_sources: Bundle Programming Guide|https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/
expansion_of: Weeks/01-darwin-filesystem.md
activities: map-filesystem | inspect-bundles | record-findings
---
```

## Recomendação para o próximo marco

Após a migração Git, o checklist Apple atual deve ser refatorado para:

- nascer da árvore documental, não de uma sequência linear isolada
- concentrar tarefas e entregáveis em blocos mais instrutivos
- usar expansões em vez de repetição de conteúdo longo
- persistir metadata suficiente para futura visualização relacional no app

## Impacto esperado no app

Com esse contrato, o app poderá evoluir para:

- mostrar arquivos relacionados à sessão ativa
- abrir a árvore de origem do conteúdo atual
- filtrar por `tags`
- visualizar expansões e subtemas sem rolagem excessiva
- explicar de onde veio cada atividade e qual documentação a sustenta

## Referências internas

- `docs/product/implementation-plan.md`
- `docs/product/git-migration-plan.md`
- `docs/api/vault-workspace-api.md`
