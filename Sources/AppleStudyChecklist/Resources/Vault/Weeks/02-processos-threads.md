---
week_number: 2
title: Processos, threads, run loop e launchd
objective: Ler o ciclo de vida de processo no macOS e como serviços do usuário são iniciados.
deliverable: Nota técnica relacionando app lifecycle, processos e background agents.
glossary: process | thread | run loop | launchd | agent
references: Concurrency|https://developer.apple.com/documentation/swift/concurrency || Threading Programming Guide|https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ || Activity Monitor User Guide|https://support.apple.com/guide/activity-monitor/welcome/mac
---
Relacione `launchd`, Activity Monitor e o lifecycle do app com as abstrações de concorrência disponíveis em Swift.

O foco é compreender quando trabalho em background vira processo, thread, task assíncrona ou agente do usuário.
