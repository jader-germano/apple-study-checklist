import Foundation

enum StudyCatalog {
    static let program = makeProgram()

    private struct WeekBlueprint {
        let title: String
        let objective: String
        let deliverable: String
        let references: [ReferenceLink]
        let glossary: [String]
    }

    private static func makeProgram() -> StudyProgram {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let startDate = formatter.date(from: "2026-03-28") ?? .now
        let blueprints: [WeekBlueprint] = [
            WeekBlueprint(
                title: "Darwin, filesystem e app bundles",
                objective: "Entender como o macOS organiza apps, diretórios de usuário, bundles e metadados.",
                deliverable: "Mapa comentado do filesystem Apple + inspeção de 3 bundles reais.",
                references: [
                    ReferenceLink(title: "macOS", url: "https://developer.apple.com/macos/"),
                    ReferenceLink(title: "Bundle Programming Guide", url: "https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/"),
                    ReferenceLink(title: "FileManager", url: "https://developer.apple.com/documentation/foundation/filemanager")
                ],
                glossary: ["Darwin", "bundle", "Info.plist", "Application Support", "sandbox container"]
            ),
            WeekBlueprint(
                title: "Processos, threads, run loop e launchd",
                objective: "Ler o ciclo de vida de processo no macOS e como serviços do usuário são iniciados.",
                deliverable: "Nota técnica relacionando app lifecycle, processos e background agents.",
                references: [
                    ReferenceLink(title: "Concurrency", url: "https://developer.apple.com/documentation/swift/concurrency"),
                    ReferenceLink(title: "Threading Programming Guide", url: "https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/"),
                    ReferenceLink(title: "Activity Monitor User Guide", url: "https://support.apple.com/guide/activity-monitor/welcome/mac")
                ],
                glossary: ["process", "thread", "run loop", "launchd", "agent"]
            ),
            WeekBlueprint(
                title: "Sandbox, entitlements e permissões",
                objective: "Entender o isolamento do app e o que precisa ser declarado para acessar recursos do sistema.",
                deliverable: "Checklist de permissões e entitlements para um app macOS moderno.",
                references: [
                    ReferenceLink(title: "App Sandbox", url: "https://developer.apple.com/documentation/security/app-sandbox"),
                    ReferenceLink(title: "Configuring the macOS App Sandbox", url: "https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox/"),
                    ReferenceLink(title: "Apple Platform Security", url: "https://support.apple.com/guide/security/welcome/web")
                ],
                glossary: ["entitlement", "TCC", "permission prompt", "container", "capability"]
            ),
            WeekBlueprint(
                title: "Code signing, notarization e distribuição",
                objective: "Entender como um app Apple é assinado, validado e distribuído no macOS.",
                deliverable: "Fluxo documentado de assinatura e notarização.",
                references: [
                    ReferenceLink(title: "Code Signing Guide", url: "https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html"),
                    ReferenceLink(title: "Notarizing macOS software", url: "https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution"),
                    ReferenceLink(title: "Developer ID", url: "https://developer.apple.com/developer-id/")
                ],
                glossary: ["codesign", "notarization", "Developer ID", "hardened runtime", "provisioning"]
            ),
            WeekBlueprint(
                title: "Swift base e modelagem",
                objective: "Dominar tipos, protocolos, erros, memória e composição em Swift.",
                deliverable: "CLI em Swift para inspecionar bundles e metadados.",
                references: [
                    ReferenceLink(title: "Swift", url: "https://developer.apple.com/swift/"),
                    ReferenceLink(title: "The Swift Programming Language", url: "https://www.swift.org/documentation/tspl/"),
                    ReferenceLink(title: "Swift Standard Library", url: "https://developer.apple.com/documentation/swift/swift-standard-library")
                ],
                glossary: ["ARC", "struct", "class", "protocol", "actor"]
            ),
            WeekBlueprint(
                title: "Foundation, IO e rede",
                objective: "Usar Foundation para arquivos, dados, datas, serialização e URLSession.",
                deliverable: "Ferramenta local com leitura/escrita em disco e request HTTP assíncrono.",
                references: [
                    ReferenceLink(title: "Foundation", url: "https://developer.apple.com/documentation/foundation"),
                    ReferenceLink(title: "URLSession", url: "https://developer.apple.com/documentation/foundation/urlsession"),
                    ReferenceLink(title: "Codable", url: "https://developer.apple.com/documentation/swift/codable")
                ],
                glossary: ["Codable", "URLSession", "JSONDecoder", "async/await", "FileManager"]
            ),
            WeekBlueprint(
                title: "SwiftUI app lifecycle e estado",
                objective: "Aprender App, Scene, fluxo de estado, bindings e navegação.",
                deliverable: "App SwiftUI macOS+iOS com 2 telas e estado coerente.",
                references: [
                    ReferenceLink(title: "SwiftUI Concepts", url: "https://developer.apple.com/tutorials/swiftui-concepts"),
                    ReferenceLink(title: "Scene", url: "https://developer.apple.com/documentation/swiftui/scene"),
                    ReferenceLink(title: "Managing model data", url: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app")
                ],
                glossary: ["App", "Scene", "@State", "@Observable", "Binding"]
            ),
            WeekBlueprint(
                title: "AppKit e interoperabilidade",
                objective: "Saber quando SwiftUI não basta e como integrar menus, janelas e configurações do macOS.",
                deliverable: "Tela SwiftUI com uma ponte útil para AppKit.",
                references: [
                    ReferenceLink(title: "AppKit", url: "https://developer.apple.com/documentation/appkit"),
                    ReferenceLink(title: "NSWindow", url: "https://developer.apple.com/documentation/appkit/nswindow"),
                    ReferenceLink(title: "Commands", url: "https://developer.apple.com/documentation/swiftui/commands")
                ],
                glossary: ["AppKit", "NSViewRepresentable", "menu command", "window scene", "settings"]
            ),
            WeekBlueprint(
                title: "Persistência e segurança de dados",
                objective: "Dominar SwiftData/Core Data, Keychain e modelagem de dados do app.",
                deliverable: "App de notas local com persistência e armazenamento seguro.",
                references: [
                    ReferenceLink(title: "SwiftData", url: "https://developer.apple.com/documentation/swiftdata"),
                    ReferenceLink(title: "Core Data", url: "https://developer.apple.com/documentation/coredata"),
                    ReferenceLink(title: "Keychain Services", url: "https://developer.apple.com/documentation/security/keychain_services")
                ],
                glossary: ["SwiftData", "Core Data", "schema", "migration", "Keychain"]
            ),
            WeekBlueprint(
                title: "Integração com sistema e background work",
                objective: "Trabalhar com notificações, import/export, tasks de background e acesso a arquivos.",
                deliverable: "App com exportação e atualização em background minimamente robusta.",
                references: [
                    ReferenceLink(title: "Background Tasks", url: "https://developer.apple.com/documentation/backgroundtasks"),
                    ReferenceLink(title: "UserNotifications", url: "https://developer.apple.com/documentation/usernotifications"),
                    ReferenceLink(title: "Document-based apps", url: "https://developer.apple.com/documentation/appkit/document-based_applications")
                ],
                glossary: ["background task", "notification", "document", "export", "import"]
            ),
            WeekBlueprint(
                title: "Widgets, intents, extensões e Shortcuts",
                objective: "Entender os pontos de extensão do ecossistema Apple e automação com intents.",
                deliverable: "Uma extensão ou atalho funcional ligado ao app principal.",
                references: [
                    ReferenceLink(title: "App Intents", url: "https://developer.apple.com/documentation/appintents"),
                    ReferenceLink(title: "WidgetKit", url: "https://developer.apple.com/documentation/widgetkit"),
                    ReferenceLink(title: "App extensions", url: "https://developer.apple.com/documentation/uikit/app-extensions")
                ],
                glossary: ["App Intent", "widget", "extension", "shortcut", "deep link"]
            ),
            WeekBlueprint(
                title: "Testes, performance e release",
                objective: "Medir qualidade, debugar performance e preparar distribuição real.",
                deliverable: "Build testado, profile básico e release checklist.",
                references: [
                    ReferenceLink(title: "Testing", url: "https://developer.apple.com/documentation/testing"),
                    ReferenceLink(title: "XCTest", url: "https://developer.apple.com/documentation/xctest"),
                    ReferenceLink(title: "Performance and metrics", url: "https://developer.apple.com/documentation/xcode/performance-and-metrics")
                ],
                glossary: ["XCTest", "Instruments", "profiling", "regression", "release checklist"]
            )
        ]

        let weeks = blueprints.enumerated().map { offset, blueprint in
            makeWeek(
                weekNumber: offset + 1,
                blueprint: blueprint,
                startOffset: offset * 7
            )
        }

        return StudyProgram(
            title: "Apple OS Developer Track",
            startDate: startDate,
            scheduleLabel: "Bloco diário sugerido: 08:00-09:30",
            weeks: weeks
        )
    }

    private static func makeWeek(weekNumber: Int, blueprint: WeekBlueprint, startOffset: Int) -> WeekPlan {
        let phases = [
            "Mapa do tema",
            "Leitura guiada",
            "Laboratório A",
            "Arquitetura e integração",
            "Laboratório B",
            "Revisão técnica",
            "Síntese e checklist"
        ]

        let days = phases.enumerated().map { index, phase in
            makeDay(
                weekNumber: weekNumber,
                dayIndex: index,
                phase: phase,
                blueprint: blueprint,
                dateOffset: startOffset + index
            )
        }

        return WeekPlan(
            id: "week-\(weekNumber)",
            weekNumber: weekNumber,
            title: blueprint.title,
            objective: blueprint.objective,
            deliverable: blueprint.deliverable,
            references: blueprint.references,
            glossary: blueprint.glossary,
            studyText: blueprint.objective,
            days: days
        )
    }

    private static func makeDay(
        weekNumber: Int,
        dayIndex: Int,
        phase: String,
        blueprint: WeekBlueprint,
        dateOffset: Int
    ) -> StudyDayPlan {
        let id = "week-\(weekNumber)-day-\(dayIndex + 1)"
        let title = "Dia \(dayIndex + 1)"
        let tasks = makeTasks(
            weekNumber: weekNumber,
            dayIndex: dayIndex,
            phase: phase,
            blueprint: blueprint
        )

        return StudyDayPlan(
            id: id,
            title: title,
            phase: phase,
            dateOffset: dateOffset,
            focus: blueprint.objective,
            output: blueprint.deliverable,
            tasks: tasks
        )
    }

    private static func makeTasks(
        weekNumber: Int,
        dayIndex: Int,
        phase: String,
        blueprint: WeekBlueprint
    ) -> [StudyTask] {
        let baseID = "week-\(weekNumber)-day-\(dayIndex + 1)"

        let definitions: [(String, String)] = [
            (
                "Ler o bloco principal do tema",
                "Foque em \(blueprint.title.lowercased()) e registre os termos que ainda estão frágeis."
            ),
            (
                "Executar uma atividade prática",
                "Conecte a leitura à prática usando o objetivo: \(blueprint.objective)"
            ),
            (
                "Registrar uma saída objetiva",
                "Atualize suas notas com um resultado verificável: \(blueprint.deliverable)"
            )
        ]

        return definitions.enumerated().map { offset, item in
            StudyTask(
                id: "\(baseID)-task-\(offset + 1)",
                title: "\(phase): \(item.0)",
                note: item.1
            )
        }
    }
}
