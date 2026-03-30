---
week_number: 3
title: Sandbox, entitlements e permissões
objective: Entender o isolamento do app e o que precisa ser declarado para acessar recursos do sistema.
deliverable: Checklist de permissões e entitlements para um app macOS moderno.
glossary: entitlement | TCC | permission prompt | container | capability
references: App Sandbox|https://developer.apple.com/documentation/security/app-sandbox || Configuring the macOS App Sandbox|https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox/ || Apple Platform Security|https://support.apple.com/guide/security/welcome/web
tags: security|sandbox|entitlements|permissions
source_tree: docs-tree/apple-platform-foundations
source_nodes: 01-darwin-filesystem.md|04-code-signing-notarization.md
related_files: 01-darwin-filesystem.md|04-code-signing-notarization.md
activities: inspect-entitlements|test-sandbox
---
Modele o caminho completo entre uma ação do usuário, a capability declarada no projeto e a checagem do sistema operacional.

Registre quais recursos exigem prompt, quais dependem de entitlement e quais falham silenciosamente em ambiente restrito.
