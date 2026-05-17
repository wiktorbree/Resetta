import SwiftUI

struct SettingsView: View {
    @AppStorage(UserSettings.StorageKey.endConfirmationEnabled) private var endConfirmationEnabled = UserSettings.defaults.endConfirmationEnabled
    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @AppStorage(UserSettings.StorageKey.keepScreenAwake) private var keepScreenAwake = UserSettings.defaults.keepScreenAwake
    @AppStorage(UserSettings.StorageKey.pureBlackModeEnabled) private var pureBlackModeEnabled = UserSettings.defaults.pureBlackModeEnabled
    @AppStorage(UserSettings.StorageKey.dailyReminderEnabled) private var dailyReminderEnabled = UserSettings.defaults.dailyReminderEnabled

    var body: some View {
        Form {
            Section("Session") {
                Toggle("Keep screen awake during session", isOn: $keepScreenAwake)
                Toggle("Gentle haptics", isOn: $hapticsEnabled)
                Toggle("End confirmation", isOn: $endConfirmationEnabled)
            }

            Section("Appearance") {
                Toggle("Pure Black Mode", isOn: $pureBlackModeEnabled)
            }

            Section("Reminders") {
                Toggle("Daily reminder", isOn: $dailyReminderEnabled)
            }

            Section("Privacy") {
                Text("Resetta stores sessions on this device. No account. No tracking.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("App", value: "Resetta")
                LabeledContent("Version", value: "1.0")
                Text("Do nothing. On purpose.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .portraitOnlyOrientationScope()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
