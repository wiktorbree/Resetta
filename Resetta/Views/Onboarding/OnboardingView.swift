import SwiftUI

struct OnboardingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let onComplete: () -> Void
    private let onStartFirstSession: (TimeInterval) -> Void

    private static let pages = [
        OnboardingPage(
            title: "Your brain wasn't built for infinite stimulation.",
            bodyText: "The feed always has another thing. You do not have to keep meeting it.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            title: "Silence feels uncomfortable first.",
            bodyText: "That first restless minute is not failure. It is your attention settling.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            title: "This app does almost nothing. That's the point.",
            bodyText: "No feed. No streak pressure. Start with two quiet minutes and put the phone down.",
            buttonTitle: "Start 2-minute detox",
            secondaryButtonTitle: "Not now",
            suggestedDuration: 2 * 60
        )
    ]

    @State private var pageIndex = 0

    init(
        onComplete: @escaping () -> Void,
        onStartFirstSession: @escaping (TimeInterval) -> Void
    ) {
        self.onComplete = onComplete
        self.onStartFirstSession = onStartFirstSession
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    Spacer(minLength: 36)

                    OnboardingPageView(
                        title: currentPage.title,
                        bodyText: currentPage.bodyText,
                        suggestedMinutes: currentPage.suggestedMinutes
                    )
                    .id(pageIndex)
                    .transition(.opacity)

                    Spacer(minLength: 34)

                    footer
                }
                .padding(.horizontal, 28)
                .padding(.top, 30)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(Color(.systemBackground))
        .portraitOnlyOrientationScope()
    }

    private var header: some View {
        HStack {
            Text("Resetta")
                .font(.headline.weight(.semibold))
                .foregroundStyle(ResettaTheme.accentText)

            Spacer()
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            pageIndicator

            Button(action: primaryAction) {
                Text(currentPage.buttonTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(ResettaTheme.accent)
            .controlSize(.large)
            .accessibilityLabel(currentPage.buttonTitle)

            if let secondaryButtonTitle = currentPage.secondaryButtonTitle {
                Button(secondaryButtonTitle, action: onComplete)
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Self.pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? ResettaTheme.accentText : Color.secondary.opacity(0.22))
                    .frame(width: index == pageIndex ? 24 : 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }

    private var currentPage: OnboardingPage {
        Self.pages[pageIndex]
    }

    private func primaryAction() {
        if let suggestedDuration = currentPage.suggestedDuration {
            onStartFirstSession(suggestedDuration)
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
    var secondaryButtonTitle: String?
    var suggestedDuration: TimeInterval?

    var suggestedMinutes: Int? {
        guard let suggestedDuration else { return nil }

        return Int(suggestedDuration / 60)
    }
}

#Preview {
    OnboardingView(onComplete: {}, onStartFirstSession: { _ in })
}
