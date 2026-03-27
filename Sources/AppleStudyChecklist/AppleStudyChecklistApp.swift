import SwiftUI

@main
struct AppleStudyChecklistApp: App {
    @StateObject private var store = StudyStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
#if os(macOS)
        .defaultSize(width: 1240, height: 820)
#endif
    }
}
