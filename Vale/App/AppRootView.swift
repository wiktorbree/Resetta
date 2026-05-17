import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(UserSettings.StorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(UserSettings.StorageKey.remindersEnabled) private var remindersEnabled = UserSettings.defaults.remindersEnabled
    @AppStorage(UserSettings.StorageKey.reminderHour) private var reminderHour = UserSettings.defaults.reminderHour
    @AppStorage(UserSettings.StorageKey.reminderMinute) private var reminderMinute = UserSettings.defaults.reminderMinute
    @State private var onboardingStarterSession: OnboardingStarterSession?

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
                    .transition(ValeTheme.calmTransition)
            } else {
                OnboardingView(
                    onComplete: completeOnboarding,
                    onStartFirstSession: startFirstSession(duration:)
                )
                .transition(ValeTheme.calmTransition)
            }
        }
        .animation(ValeTheme.calmAnimation(reduceMotion: reduceMotion, duration: 0.32), value: hasCompletedOnboarding)
        .fullScreenCover(item: $onboardingStarterSession) { session in
            SessionFlowView(duration: session.duration)
        }
        .portraitOnlyOrientationScope()
        .task {
            await reconcileReminderSettings()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await reconcileReminderSettings()
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func startFirstSession(duration: TimeInterval) {
        hasCompletedOnboarding = true
        onboardingStarterSession = OnboardingStarterSession(duration: duration)
    }

    private func reconcileReminderSettings() async {
        let normalizedHour = UserSettings.normalizedReminderHour(reminderHour)
        let normalizedMinute = UserSettings.normalizedReminderMinute(reminderMinute)

        if reminderHour != normalizedHour {
            reminderHour = normalizedHour
        }

        if reminderMinute != normalizedMinute {
            reminderMinute = normalizedMinute
        }

        let result = await NotificationService.shared.synchronizeDailyReminder(
            enabled: remindersEnabled,
            hour: normalizedHour,
            minute: normalizedMinute,
            requestPermissionIfNeeded: false
        )

        switch result {
        case .scheduled, .disabled:
            break
        case .permissionDenied, .permissionNotDetermined, .schedulingFailed:
            remindersEnabled = false
        }
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
