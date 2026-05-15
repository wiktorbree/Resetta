import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \DetoxSession.startDate, order: .reverse) private var sessions: [DetoxSession]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No sessions yet",
                    systemImage: "timer",
                    description: Text("Quiet time will appear here.")
                )
            } else {
                List {
                    Section {
                        HistorySummaryView(
                            quietTimeThisWeek: quietTimeThisWeek,
                            sessionsThisWeek: weekSessions.count,
                            longestSession: longestSession
                        )
                    }

                    Section("Days") {
                        ForEach(dayGroups) { group in
                            NavigationLink {
                                DayDetailView(date: group.date, sessions: group.sessions)
                            } label: {
                                CalendarDayCell(date: group.date, sessions: group.sessions)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .portraitOnlyOrientationScope()
    }

    private var weekSessions: [DetoxSession] {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else {
            return []
        }

        return sessions.filter { week.contains($0.startDate) }
    }

    private var quietTimeThisWeek: TimeInterval {
        weekSessions.reduce(0) { $0 + $1.actualDuration }
    }

    private var longestSession: TimeInterval {
        sessions.map(\.actualDuration).max() ?? 0
    }

    private var dayGroups: [SessionDayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startDate)
        }

        return grouped.keys
            .sorted(by: >)
            .map { date in
                SessionDayGroup(date: date, sessions: grouped[date] ?? [])
            }
    }
}

private struct HistorySummaryView: View {
    let quietTimeThisWeek: TimeInterval
    let sessionsThisWeek: Int
    let longestSession: TimeInterval

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                SummaryMetric(title: "This week", value: TimeFormatting.duration(quietTimeThisWeek))
                Divider()
                SummaryMetric(title: "Sessions", value: "\(sessionsThisWeek)")
                Divider()
                SummaryMetric(title: "Longest", value: TimeFormatting.duration(longestSession))
            }
        }
        .padding(.vertical, 8)
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.monospacedDigit())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SessionDayGroup: Identifiable {
    let date: Date
    let sessions: [DetoxSession]

    var id: Date { date }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: DetoxSession.self, inMemory: true)
}
