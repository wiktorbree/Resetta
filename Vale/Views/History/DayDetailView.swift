import SwiftUI

struct DayDetailView: View {
    let date: Date
    let sessions: [DetoxSession]

    @ScaledMetric(relativeTo: .largeTitle) private var totalDurationFontSize: CGFloat = 44

    private var sortedSessions: [DetoxSession] {
        sessions.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(TimeFormatting.duration(totalDuration))
                        .font(.system(size: totalDurationFontSize, weight: .medium, design: .default).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 0) {
                    ForEach(sortedSessions.indices, id: \.self) { index in
                        SessionDetailRow(session: sortedSessions[index])

                        if index < sortedSessions.count - 1 {
                            Divider()
                                .hidden()
                                .overlay(ValeTheme.subtleLine)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .background(ValeTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
        .background(ValeTheme.screenBackground.ignoresSafeArea())
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .portraitOnlyOrientationScope()
    }

    private var totalDuration: TimeInterval {
        sessions.reduce(0) { $0 + $1.actualDuration }
    }

    private var summaryText: String {
        let sessionText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        return "\(sessionText) on \(date.formatted(date: .long, time: .omitted))"
    }
}

private struct SessionDetailRow: View {
    let session: DetoxSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    Text(timeRangeText)
                        .font(.headline)

                    Spacer(minLength: 12)

                    Text(TimeFormatting.duration(session.actualDuration))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(timeRangeText)
                        .font(.headline)

                    Text(TimeFormatting.duration(session.actualDuration))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                if let intent = session.intent {
                    DetailLine(title: "Intent", value: intent.rawValue)
                }

                if let feeling = session.feeling {
                    DetailLine(title: "Feeling", value: feeling.rawValue)
                }

                if let note = session.note {
                    Text(note)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 18)
    }

    private var timeRangeText: String {
        "\(TimeFormatting.clockTime(session.startDate)) - \(TimeFormatting.clockTime(session.endDate))"
    }
}

private struct DetailLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundStyle(.secondary)

            Text(value)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        DayDetailView(
            date: Date(),
            sessions: [
                DetoxSession(
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(30 * 60),
                    plannedDuration: 30 * 60,
                    actualDuration: 30 * 60,
                    completed: true,
                    intent: .rest,
                    feeling: .calm,
                    note: "Quiet and simple."
                )
            ]
        )
    }
}
