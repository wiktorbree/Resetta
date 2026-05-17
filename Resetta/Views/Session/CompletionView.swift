import SwiftUI

struct CompletionView: View {
    let session: DetoxSession
    let onReflect: () -> Void
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    Spacer(minLength: 48)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(session.completed ? "Session complete." : "Session ended.")
                            .font(.title.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(bodyText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 48)

                    VStack(spacing: 12) {
                        Button(action: onReflect) {
                            Text("Reflect")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 54)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(ResettaTheme.accent)

                        Button(action: onDone) {
                            Text("Done")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(Color(.systemBackground))
        .portraitOnlyOrientationScope()
    }

    private var bodyText: String {
        let duration = TimeFormatting.duration(session.actualDuration)

        if session.completed {
            return "You spent \(duration) without stimulation."
        }

        return "You stepped away for \(duration)."
    }
}

#Preview {
    CompletionView(
        session: DetoxSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(15 * 60),
            plannedDuration: 15 * 60,
            actualDuration: 15 * 60,
            completed: true,
            intent: .doNothing
        ),
        onReflect: {},
        onDone: {}
    )
}
