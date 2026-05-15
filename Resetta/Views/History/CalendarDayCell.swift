import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let sessions: [DetoxSession]

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(ResettaTheme.accent.opacity(dotOpacity))
                .frame(width: dotSize, height: dotSize)
                .frame(width: 18, height: 18)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)

                Text(sessionCountText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(TimeFormatting.duration(totalDuration))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.actualDuration }
    }

    private var sessionCountText: String {
        sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
    }

    private var dotSize: CGFloat {
        min(14, 7 + CGFloat(totalDuration / 600))
    }

    private var dotOpacity: Double {
        min(0.95, 0.35 + totalDuration / 3600)
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
        ]
    )
    .padding()
}
