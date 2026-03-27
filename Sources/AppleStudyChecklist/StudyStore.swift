import Foundation
import SwiftUI

@MainActor
final class StudyStore: ObservableObject {
    @Published private(set) var program = StudyCatalog.program
    @Published private var completedTaskIDs: Set<String> = []

    private let saveURL: URL

    init() {
        self.saveURL = Self.makeSaveURL()
        load()
    }

    func isCompleted(_ taskID: String) -> Bool {
        completedTaskIDs.contains(taskID)
    }

    func binding(for taskID: String) -> Binding<Bool> {
        Binding(
            get: { self.completedTaskIDs.contains(taskID) },
            set: { isOn in
                if isOn {
                    self.completedTaskIDs.insert(taskID)
                } else {
                    self.completedTaskIDs.remove(taskID)
                }
                self.save()
            }
        )
    }

    func completedCount(for day: StudyDayPlan) -> Int {
        day.tasks.filter { completedTaskIDs.contains($0.id) }.count
    }

    func progress(for week: WeekPlan) -> Double {
        let taskIDs = week.days.flatMap(\.tasks).map(\.id)
        guard taskIDs.isEmpty == false else { return 0 }
        let completed = taskIDs.filter { completedTaskIDs.contains($0) }.count
        return Double(completed) / Double(taskIDs.count)
    }

    func reset(_ week: WeekPlan) {
        let ids = Set(week.days.flatMap(\.tasks).map(\.id))
        completedTaskIDs.subtract(ids)
        save()
    }

    private func load() {
        guard
            let data = try? Data(contentsOf: saveURL),
            let payload = try? JSONDecoder().decode(PersistedProgress.self, from: data)
        else {
            return
        }

        completedTaskIDs = Set(payload.completedTaskIDs)
    }

    private func save() {
        let payload = PersistedProgress(completedTaskIDs: Array(completedTaskIDs).sorted())
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private static func makeSaveURL() -> URL {
        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(filePath: NSTemporaryDirectory())
        let folderURL = baseURL.appendingPathComponent("AppleStudyChecklist", isDirectory: true)
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL.appendingPathComponent("progress.json")
    }
}

private struct PersistedProgress: Codable {
    let completedTaskIDs: [String]
}
