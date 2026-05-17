import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let sessions: [DetoxSession]
    let isInDisplayedMonth: Bool
    let isToday: Bool
    let maxDayDuration: TimeInterval

    var body: some View {
        VStack(spacing: 7) {
            Text("\(dayNumber)")
                .font(.callout.weight(isToday ? .semibold : .regular).monospacedDigit())
                .foregroundStyle(dayForegroundStyle)
                .frame(width: 30, height: 30)
                .background {
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(ValeTheme.accentText.opacity(0.14))
                    }
                }

            Circle()
                .fill(ValeTheme.accentText)
                .frame(width: dotSize, height: dotSize)
                .opacity(dotOpacity)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var dayForegroundStyle: some ShapeStyle {
        if isToday {
            return AnyShapeStyle(ValeTheme.accentText)
        }

        return AnyShapeStyle(isInDisplayedMonth ? Color.primary : Color.secondary.opacity(0.45))
    }

    private var totalDuration: TimeInterval {
        sessions
            .reduce(0) { $0 + $1.actualDuration }
    }

    private var dotSize: CGFloat {
        guard !sessions.isEmpty else {
            return 4
        }

        return 5 + CGFloat(durationScale * 5)
    }

    private var dotOpacity: Double {
        guard !sessions.isEmpty else {
            return 0
        }

        return 0.35 + durationScale * 0.55
    }

    private var durationScale: Double {
        guard maxDayDuration > 0 else {
            return 0
        }

        return min(1, totalDuration / maxDayDuration)
    }

    private var accessibilityLabel: String {
        let dateText = date.formatted(date: .abbreviated, time: .omitted)

        guard !sessions.isEmpty else {
            return "\(dateText), no sessions"
        }

        let sessionText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        return "\(dateText), \(TimeFormatting.duration(totalDuration)), \(sessionText)"
    }
}

#Preview {
    CalendarDayCell(
        date: Date(),
        sessions: [
            DetoxSession(
                startDate: Date(),
                endDate: Date().addingTimeInterval(15 * 60),
                plannedDuration: 15 * 60,
                actualDuration: 15 * 60,
                completed: true
            )
        ],
        isInDisplayedMonth: true,
        isToday: true,
        maxDayDuration: 45 * 60
    )
    .padding()
}
