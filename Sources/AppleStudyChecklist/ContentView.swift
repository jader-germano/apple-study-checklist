import SwiftUI

struct ContentView: View {
    @ObservedObject var store: StudyStore
    @State private var selectedWeekID = StudyCatalog.program.weeks.first?.id

    private var selectedWeek: WeekPlan? {
        store.program.weeks.first { $0.id == selectedWeekID }
    }

    var body: some View {
        NavigationSplitView {
            List(store.program.weeks, selection: $selectedWeekID) { week in
                WeekRowView(week: week, progress: store.progress(for: week))
                    .tag(week.id)
            }
            .navigationTitle("Plano")
        } detail: {
            if let week = selectedWeek {
                WeekDetailView(
                    program: store.program,
                    week: week,
                    store: store
                )
            } else {
                ContentUnavailableView(
                    "Selecione uma semana",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("O cronograma de estudo aparece por semana com checklist e referências.")
                )
            }
        }
        .frame(minWidth: 1100, minHeight: 760)
    }
}

private struct WeekRowView: View {
    let week: WeekPlan
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Semana \(week.weekNumber)")
                    .font(.headline)
                Spacer()
                Text(progress.formatted(.percent.precision(.fractionLength(0))))
                    .foregroundStyle(.secondary)
            }

            Text(week.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
        }
        .padding(.vertical, 4)
    }
}

private struct WeekDetailView: View {
    let program: StudyProgram
    let week: WeekPlan
    @ObservedObject var store: StudyStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                references
                glossary
                days
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Semana \(week.weekNumber)")
        .toolbar {
            Button("Resetar semana") {
                store.reset(week)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(week.title)
                .font(.largeTitle.bold())

            Text(program.scheduleLabel)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(week.objective)
                .font(.title3)

            Label(week.deliverable, systemImage: "checklist")
                .foregroundStyle(.secondary)

            ProgressView(value: store.progress(for: week))
                .tint(.blue)
        }
    }

    private var references: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Referências")
                .font(.title2.bold())

            ForEach(week.references) { reference in
                Link(destination: URL(string: reference.url)!) {
                    Label(reference.title, systemImage: "link")
                }
            }
        }
    }

    private var glossary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glossário base")
                .font(.title2.bold())

            FlowLayout(items: week.glossary) { term in
                Text(term)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }
        }
    }

    private var days: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Checklist diário")
                .font(.title2.bold())

            ForEach(week.days) { day in
                DayCardView(
                    program: program,
                    day: day,
                    completedCount: store.completedCount(for: day),
                    totalCount: day.tasks.count,
                    store: store
                )
            }
        }
    }
}

private struct DayCardView: View {
    let program: StudyProgram
    let day: StudyDayPlan
    let completedCount: Int
    let totalCount: Int
    @ObservedObject var store: StudyStore

    private var dateText: String {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(byAdding: .day, value: day.dateOffset, to: program.startDate) ?? program.startDate
        return date.formatted(.dateTime.weekday(.wide).day().month().year())
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(day.title) • \(day.phase)")
                            .font(.headline)
                        Text(dateText)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(completedCount)/\(totalCount)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text(day.focus)
                    .font(.subheadline)

                Label(day.output, systemImage: "doc.text")
                    .foregroundStyle(.secondary)

                Divider()

                ForEach(day.tasks) { task in
                    Toggle(isOn: store.binding(for: task.id)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                            Text(task.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.checkbox)
                }
            }
        }
    }
}

private struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
        }
    }
}
