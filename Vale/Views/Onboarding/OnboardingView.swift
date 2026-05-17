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

                    Spacer(minLength: 52)

                    OnboardingPageView(
                        title: currentPage.title,
                        bodyText: currentPage.bodyText,
                        suggestedMinutes: currentPage.suggestedMinutes
                    )
                    .id(pageIndex)
                    .transition(ValeTheme.calmTransition)

                    Spacer(minLength: 44)

                    footer
                }
                .padding(.horizontal, ValeTheme.horizontalPadding(for: proxy.size.width))
                .padding(.top, max(30, proxy.safeAreaInsets.top + 14))
                .padding(.bottom, max(30, proxy.safeAreaInsets.bottom + 24))
                .frame(maxWidth: ValeTheme.contentWidth(for: proxy.size.width), minHeight: proxy.size.height, alignment: .top)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(ValeTheme.screenBackground.ignoresSafeArea())
        .portraitOnlyOrientationScope()
    }

    private var header: some View {
        HStack {
            Text("Vale")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ValeTheme.accentText)

            Spacer()
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            pageIndicator

            Button(action: primaryAction) {
                Text(currentPage.buttonTitle)
            }
            .buttonStyle(ValePrimaryButtonStyle())
            .accessibilityLabel(currentPage.buttonTitle)

            if let secondaryButtonTitle = currentPage.secondaryButtonTitle {
                Button(secondaryButtonTitle, action: onComplete)
                    .buttonStyle(ValeQuietButtonStyle(foregroundStyle: AnyShapeStyle(Color.secondary)))
                    .padding(.top, 2)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Self.pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? ValeTheme.accentText : Color.secondary.opacity(0.22))
                    .frame(width: 7, height: 7)
                    .opacity(index == pageIndex ? 1 : 0.44)
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

        withAnimation(ValeTheme.calmAnimation(reduceMotion: reduceMotion, duration: 0.3)) {
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
