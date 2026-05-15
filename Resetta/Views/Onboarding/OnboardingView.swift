import SwiftUI

struct OnboardingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let onComplete: () -> Void
    private static let pages = [
        OnboardingPage(
            title: "Your brain wasn't built for infinite stimulation.",
            bodyText: "Every scroll, swipe and notification trains your mind to escape boredom.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            title: "Silence feels uncomfortable first.",
            bodyText: "That discomfort is the point. Sit with it. Let your brain reset.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            title: "This app does almost nothing.",
            bodyText: "No feeds. No badges. No rewards. Just time away from stimulation.",
            buttonTitle: "Start your first detox"
        ),
        OnboardingPage(
            title: "Start small.",
            bodyText: "Try a short reset. Put your phone down. Do nothing.",
            buttonTitle: "Begin"
        )
    ]

    @State private var pageIndex = 0

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Resetta")
                .font(.headline.weight(.semibold))
                .foregroundStyle(ResettaTheme.accent)

            Spacer(minLength: 40)

            OnboardingPageView(
                title: currentPage.title,
                bodyText: currentPage.bodyText
            )
            .id(pageIndex)
            .transition(.opacity)

            Spacer(minLength: 40)

            HStack(spacing: 8) {
                ForEach(Self.pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == pageIndex ? ResettaTheme.accent : Color.secondary.opacity(0.22))
                        .frame(width: index == pageIndex ? 24 : 8, height: 8)
                }
            }
            .accessibilityHidden(true)

            Button(action: advance) {
                Text(currentPage.buttonTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(ResettaTheme.accent)
            .controlSize(.large)
            .accessibilityLabel(currentPage.buttonTitle)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .portraitOnlyOrientationScope()
    }

    private var currentPage: OnboardingPage {
        Self.pages[pageIndex]
    }

    private func advance() {
        if pageIndex == Self.pages.count - 1 {
            onComplete()
            return
        }

        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
            pageIndex += 1
        }
    }
}

private struct OnboardingPage {
    let title: String
    let bodyText: String
    let buttonTitle: String
}

#Preview {
    OnboardingView(onComplete: {})
}
