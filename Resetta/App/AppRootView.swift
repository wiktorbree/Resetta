import SwiftUI
import SwiftData

struct AppRootView: View {
    @AppStorage(UserSettings.StorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var onboardingStarterSession: OnboardingStarterSession?

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(
                    onComplete: completeOnboarding,
                    onStartFirstSession: startFirstSession(duration:)
                )
            }
        }
        .fullScreenCover(item: $onboardingStarterSession) { session in
            SessionFlowView(duration: session.duration)
        }
        .portraitOnlyOrientationScope()
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func startFirstSession(duration: TimeInterval) {
        hasCompletedOnboarding = true
        onboardingStarterSession = OnboardingStarterSession(duration: duration)
    }
}

private struct OnboardingStarterSession: Identifiable {
    let id = UUID()
    let duration: TimeInterval
}

#Preview {
    AppRootView()
        .environment(SessionTimerService())
        .environment(SessionStorageService())
        .modelContainer(for: DetoxSession.self, inMemory: true)
}
