import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage(UserSettings.StorageKey.endConfirmationEnabled) private var endConfirmationEnabled = UserSettings.defaults.endConfirmationEnabled
    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @AppStorage(UserSettings.StorageKey.keepScreenAwake) private var keepScreenAwake = UserSettings.defaults.keepScreenAwake
    @AppStorage(UserSettings.StorageKey.pureBlackModeEnabled) private var pureBlackModeEnabled = UserSettings.defaults.pureBlackModeEnabled
    @AppStorage(UserSettings.StorageKey.remindersEnabled) private var remindersEnabled = UserSettings.defaults.remindersEnabled
    @AppStorage(UserSettings.StorageKey.reminderHour) private var reminderHour = UserSettings.defaults.reminderHour
    @AppStorage(UserSettings.StorageKey.reminderMinute) private var reminderMinute = UserSettings.defaults.reminderMinute
    @State private var showsNotificationSettingsAlert = false
    @State private var reminderUpdateTask: Task<Void, Never>?

    var body: some View {
        Form {
            Section("Session") {
                Toggle("Keep screen awake during session", isOn: $keepScreenAwake)
                Toggle("Gentle haptics", isOn: $hapticsEnabled)
                Toggle("End confirmation", isOn: $endConfirmationEnabled)
            }

            Section("Appearance") {
                Toggle("Pure Black", isOn: $pureBlackModeEnabled)
            }

            Section("Reminders") {
                Toggle("Daily reminder", isOn: dailyReminderToggleBinding)

                DatePicker(
                    "Reminder time",
                    selection: reminderTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .disabled(!remindersEnabled)
            }

            Section("Privacy") {
                Text("Vale stores sessions on this device. No account. No tracking.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("App", value: "Vale")
                LabeledContent("Version", value: "1.0")
                Text("Do nothing. On purpose.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(ValeTheme.screenBackground.ignoresSafeArea())
        .tint(ValeTheme.accentText)
        .navigationTitle("Settings")
        .portraitOnlyOrientationScope()
        .alert("Notifications Disabled", isPresented: $showsNotificationSettingsAlert) {
            Button("Open Settings", action: openAppSettings)
            Button("OK", role: .cancel) {}
        } message: {
            Text("Notifications are disabled for Vale. You can enable them in Settings.")
        }
        .onDisappear {
            reminderUpdateTask?.cancel()
        }
    }

    private var dailyReminderToggleBinding: Binding<Bool> {
        Binding {
            remindersEnabled
        } set: { isEnabled in
            updateDailyReminderEnabled(isEnabled)
        }
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding {
            UserSettings.reminderTimeDate(hour: reminderHour, minute: reminderMinute)
        } set: { newValue in
            updateReminderTime(newValue)
        }
    }

    private func updateDailyReminderEnabled(_ isEnabled: Bool) {
        reminderUpdateTask?.cancel()
        remindersEnabled = isEnabled

        reminderUpdateTask = Task {
            let result = await NotificationService.shared.synchronizeDailyReminder(
                enabled: isEnabled,
                hour: reminderHour,
                minute: reminderMinute,
                requestPermissionIfNeeded: true
            )

            guard !Task.isCancelled else { return }
            handleReminderSyncResult(result)
        }
    }

    private func updateReminderTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let updatedHour = UserSettings.normalizedReminderHour(components.hour ?? UserSettings.defaults.reminderHour)
        let updatedMinute = UserSettings.normalizedReminderMinute(components.minute ?? UserSettings.defaults.reminderMinute)

        guard reminderHour != updatedHour || reminderMinute != updatedMinute else { return }

        reminderHour = updatedHour
        reminderMinute = updatedMinute

        guard remindersEnabled else { return }

        reminderUpdateTask?.cancel()
        reminderUpdateTask = Task {
            let result = await NotificationService.shared.synchronizeDailyReminder(
                enabled: true,
                hour: updatedHour,
                minute: updatedMinute,
                requestPermissionIfNeeded: false
            )

            guard !Task.isCancelled else { return }
            handleReminderSyncResult(result)
        }
    }

    private func handleReminderSyncResult(_ result: DailyReminderSyncResult) {
        switch result {
        case .scheduled, .disabled:
            break
        case .permissionDenied, .permissionNotDetermined, .schedulingFailed:
            remindersEnabled = false
            showsNotificationSettingsAlert = true
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
