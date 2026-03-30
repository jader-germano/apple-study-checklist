import SwiftUI

public struct AppleStudyChecklistRootView: View {
    @StateObject private var store = StudyStore()

    public init() {}

    public var body: some View {
        ContentView(store: store)
    }
}
