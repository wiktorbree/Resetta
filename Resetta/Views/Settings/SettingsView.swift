import SwiftUI

struct SettingsView: View {
    @AppStorage("endConfirmationEnabled") private var endConfirmationEnabled = UserSettings.defaults.endConfirmationEnabled
    @AppStorage("hapticsEnabled") private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @AppStorage("keepScreenAwake") private var keepScreenAwake = UserSettings.defaults.keepScreenAwake
    @AppStorage("pureBlackModeEnabled") private var pureBlackModeEnabled = UserSettings.defaults.pureBlackModeEnabled

    var body: some View {
        Form {
            Section("Session") {
                Toggle("Keep Screen Awake", isOn: $keepScreenAwake)
                Toggle("Gentle Haptics", isOn: $hapticsEnabled)
                Toggle("End Confirmation", isOn: $endConfirmationEnabled)
            }

            Section("Appearance") {
                Toggle("Pure Black Timer", isOn: $pureBlackModeEnabled)
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
