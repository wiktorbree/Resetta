import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \DetoxSession.startDate, order: .reverse) private var sessions: [DetoxSession]
    @State private var displayedMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                monthHeader

                if sessions.isEmpty {
                    EmptyHistoryStateView()
                } else {
                    HistoryMonthGrid(
                        calendar: calendar,
                        days: calendarDays,
                        maxDayDuration: maxDayDuration
                    )
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .portraitOnlyOrientationScope()
    }

    private var monthHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(monthTitle)
                    .font(.largeTitle.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(monthSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                monthButton(systemImage: "chevron.left", label: "Previous month") {
                    changeMonth(by: -1)
                }

                monthButton(systemImage: "chevron.right", label: "Next month") {
                    changeMonth(by: 1)
                }
            }
        }
    }

    private func monthButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(ResettaTheme.quietFill, in: Circle())
                .overlay {
                    Circle()
                        .stroke(ResettaTheme.subtleLine, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(label)
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.month(.wide).year())
    }

    private var monthSummary: String {
        let totalDuration = sessionsInDisplayedMonth.reduce(0) { $0 + $1.actualDuration }

        guard !sessionsInDisplayedMonth.isEmpty else {
            return "A quiet month."
        }

        let sessionText = sessionsInDisplayedMonth.count == 1 ? "1 session" : "\(sessionsInDisplayedMonth.count) sessions"
        return "\(TimeFormatting.duration(totalDuration)) across \(sessionText)"
    }

    private var sessionsByDay: [Date: [DetoxSession]] {
        Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startDate)
        }
    }

    private var sessionsInDisplayedMonth: [DetoxSession] {
        sessions.filter { displayedMonthInterval.contains($0.startDate) }
    }

    private var displayedMonthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: displayedMonth)
            ?? DateInterval(start: displayedMonth, duration: 30 * 24 * 60 * 60)
    }

    private var calendarDays: [HistoryCalendarDay] {
        let monthStart = displayedMonthInterval.start
        let dayRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<1
        let leadingDays = weekdayOffset(for: monthStart)
        var days: [HistoryCalendarDay] = []

        for offset in stride(from: leadingDays, to: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: monthStart) else {
                continue
            }

            days.append(calendarDay(for: date, isInDisplayedMonth: false))
        }

        for dayOffset in 0..<dayRange.count {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) else {
                continue
            }

            days.append(calendarDay(for: date, isInDisplayedMonth: true))
        }

        while days.count < 35 || !days.count.isMultiple(of: 7) {
            guard let lastDate = days.last?.date,
                  let nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate)
            else {
                break
            }

            days.append(calendarDay(for: nextDate, isInDisplayedMonth: false))
        }

        return days
    }

    private var maxDayDuration: TimeInterval {
        calendarDays
            .map(\.totalDuration)
            .max() ?? 0
    }

    private func weekdayOffset(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    private func calendarDay(for date: Date, isInDisplayedMonth: Bool) -> HistoryCalendarDay {
        let dayStart = calendar.startOfDay(for: date)

        return HistoryCalendarDay(
            date: dayStart,
            sessions: sessionsByDay[dayStart] ?? [],
            isInDisplayedMonth: isInDisplayedMonth,
            isToday: calendar.isDate(dayStart, inSameDayAs: Date())
        )
    }

    private func changeMonth(by value: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth),
              let nextMonthStart = calendar.dateInterval(of: .month, for: nextMonth)?.start
        else {
            return
        }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            displayedMonth = nextMonthStart
        }
    }
}

private struct EmptyHistoryStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "clock")
                .font(.title2.weight(.semibold))
                .foregroundStyle(ResettaTheme.accentText)
                .frame(width: 44, height: 44)
                .background(ResettaTheme.quietFill, in: Circle())
                .accessibilityHidden(true)

            Text("No sessions yet")
                .font(.title3.weight(.semibold))

            Text("Completed detox sessions will appear here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ResettaTheme.quietFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ResettaTheme.subtleLine, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct HistoryMonthGrid: View {
    let calendar: Calendar
    let days: [HistoryCalendarDay]
    let maxDayDuration: TimeInterval

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days) { day in
                    if day.sessions.isEmpty {
                        CalendarDayCell(
                            date: day.date,
                            sessions: day.sessions,
                            isInDisplayedMonth: day.isInDisplayedMonth,
                            isToday: day.isToday,
                            maxDayDuration: maxDayDuration
                        )
                    } else {
                        NavigationLink {
                            DayDetailView(date: day.date, sessions: day.sessions)
                        } label: {
                            CalendarDayCell(
                                date: day.date,
                                sessions: day.sessions,
                                isInDisplayedMonth: day.isInDisplayedMonth,
                                isToday: day.isToday,
                                maxDayDuration: maxDayDuration
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(ResettaTheme.quietFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(ResettaTheme.subtleLine, lineWidth: 1)
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startIndex = max(0, calendar.firstWeekday - 1)

        return Array(symbols[startIndex..<symbols.count]) + Array(symbols[0..<startIndex])
    }
}

private struct HistoryCalendarDay: Identifiable {
    let date: Date
    let sessions: [DetoxSession]
    let isInDisplayedMonth: Bool
    let isToday: Bool

    var id: Date { date }

    var totalDuration: TimeInterval {
        sessions
            .reduce(0) { $0 + $1.actualDuration }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: DetoxSession.self, inMemory: true)
}
