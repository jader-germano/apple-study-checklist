---
week_number: 8
title: AppKit e interoperabilidade
objective: Saber quando SwiftUI não basta e como integrar menus, janelas e configurações do macOS.
deliverable: Tela SwiftUI com uma ponte útil para AppKit.
glossary: AppKit | NSViewRepresentable | menu command | window scene | settings
references: AppKit|https://developer.apple.com/documentation/appkit || NSWindow|https://developer.apple.com/documentation/appkit/nswindow || Commands|https://developer.apple.com/documentation/swiftui/commands
tags: appkit|macos|interoperability|uikit
source_tree: docs-tree/apple-platform-foundations
source_nodes: 07-swiftui-lifecycle-state.md|09-persistencia-seguranca.md
related_files: 07-swiftui-lifecycle-state.md|09-persistencia-seguranca.md
activities: bridge-appkit|implement-nsview
---
Escolha um ponto onde SwiftUI ainda depende de APIs tradicionais do macOS e documente a integração necessária.

Priorize casos reais como seleção de pasta, janelas auxiliares, menu commands e preferências do app.
