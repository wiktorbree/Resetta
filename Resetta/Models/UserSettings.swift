import Foundation

struct UserSettings: Codable, Hashable {
    var keepScreenAwake: Bool
    var hapticsEnabled: Bool
    var endConfirmationEnabled: Bool
    var pureBlackModeEnabled: Bool
    var dailyReminderEnabled: Bool
    var dailyReminderDate: Date?

    enum StorageKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let keepScreenAwake = "keepScreenAwake"
        static let hapticsEnabled = "hapticsEnabled"
        static let endConfirmationEnabled = "endConfirmationEnabled"
        static let pureBlackModeEnabled = "pureBlackModeEnabled"
        static let dailyReminderEnabled = "dailyReminderEnabled"
    }

    static let defaults = UserSettings(
        keepScreenAwake: true,
        hapticsEnabled: true,
        endConfirmationEnabled: true,
        pureBlackModeEnabled: true,
        dailyReminderEnabled: false,
        dailyReminderDate: nil
    )
}
