import SwiftUI
import SwiftData

struct AppRootView: View {
    @AppStorage(UserSettings.StorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(onComplete: completeOnboarding)
            }
        }
        .onAppear {
            OrientationService.shared.lockPortrait()
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

#Preview {
    AppRootView()
        .environment(SessionTimerService())
        .environment(SessionStorageService())
        .modelContainer(for: DetoxSession.self, inMemory: true)
}
