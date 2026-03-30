---
week_number: 1
title: Darwin, filesystem e app bundles
objective: Entender como o macOS organiza apps, diretórios de usuário, bundles e metadados.
deliverable: Mapa comentado do filesystem Apple e inspeção de três bundles reais.
glossary: Darwin | bundle | Info.plist | Application Support | sandbox container
references: macOS|https://developer.apple.com/macos/ || Bundle Programming Guide|https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/ || FileManager|https://developer.apple.com/documentation/foundation/filemanager
tags: apple-platform|filesystem|bundle|darwin
source_tree: docs-tree/apple-platform-foundations
source_nodes: 02-processos-threads.md|03-sandbox-entitlements.md
related_files: 02-processos-threads.md|03-sandbox-entitlements.md
activities: map-filesystem|inspect-bundles
---
Mapeie `~/Library`, `/Applications` e o interior de bundles reais para conectar diretórios, metadados e convenções de empacotamento do macOS.

Use este bloco para anotar diferenças entre arquivos do usuário, recursos embutidos no app e áreas controladas por sandbox.
