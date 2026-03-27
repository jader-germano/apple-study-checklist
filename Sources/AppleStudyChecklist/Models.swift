import Foundation

struct ReferenceLink: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let url: String

    init(title: String, url: String) {
        self.id = "\(title)|\(url)"
        self.title = title
        self.url = url
    }
}

struct StudyTask: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let note: String
}

struct StudyDayPlan: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let phase: String
    let dateOffset: Int
    let focus: String
    let output: String
    let tasks: [StudyTask]
}

struct WeekPlan: Identifiable, Hashable, Codable {
    let id: String
    let weekNumber: Int
    let title: String
    let objective: String
    let deliverable: String
    let references: [ReferenceLink]
    let glossary: [String]
    let days: [StudyDayPlan]
}

struct StudyProgram: Hashable, Codable {
    let title: String
    let startDate: Date
    let scheduleLabel: String
    let weeks: [WeekPlan]
}
