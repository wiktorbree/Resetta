import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let bodyText: String
    let suggestedMinutes: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 18) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Text(bodyText)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let suggestedMinutes {
                SuggestedSessionView(minutes: suggestedMinutes)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SuggestedSessionView: View {
    let minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()

            HStack(spacing: 16) {
                Image(systemName: "timer")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ResettaTheme.accent)
                    .frame(width: 34, height: 34)
                    .background(ResettaTheme.quietFill, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("First reset")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Text("\(minutes)-minute detox")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Suggested first reset, \(minutes)-minute detox")
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "This app does almost nothing. That's the point.",
        bodyText: "No feed. No streak pressure. Start with two quiet minutes and put the phone down.",
        suggestedMinutes: 2
    )
    .padding(28)
}
