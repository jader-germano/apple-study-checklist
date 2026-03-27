import SwiftUI

@main
struct AppleStudyChecklistApp: App {
    @StateObject private var store = StudyStore()
    @StateObject private var vaultStore = VaultStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store, vaultStore: vaultStore)
        }
        .defaultSize(width: 1240, height: 820)
    }
}
