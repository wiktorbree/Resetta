import SwiftUI

struct DayDetailView: View {
    let date: Date
    let sessions: [DetoxSession]

    private var sortedSessions: [DetoxSession] {
        sessions.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        List {
            ForEach(sortedSessions, id: \.id) { session in
                SessionDetailRow(session: session)
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            OrientationService.shared.lockPortrait()
        }
    }
}

private struct SessionDetailRow: View {
    let session: DetoxSession

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(TimeFormatting.duration(session.actualDuration))
                    .font(.headline.monospacedDigit())

                Spacer()

                Text(session.completed ? "Completed" : "Ended")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(TimeFormatting.clockTime(session.startDate))

                if let intent = session.intent {
                    Text("Intent: \(intent.rawValue)")
                }

                if let feeling = session.feeling {
                    Text("Feeling: \(feeling.rawValue)")
                }

                if let note = session.note {
                    Text(note)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
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
