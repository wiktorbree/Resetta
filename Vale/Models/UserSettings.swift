import Foundation

struct UserSettings: Codable, Hashable, Sendable {
    nonisolated static let defaultReminderHour = 20
    nonisolated static let defaultReminderMinute = 0

    var keepScreenAwake: Bool
    var hapticsEnabled: Bool
    var endConfirmationEnabled: Bool
    var pureBlackModeEnabled: Bool
    var remindersEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int

    enum StorageKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let keepScreenAwake = "keepScreenAwake"
        static let hapticsEnabled = "hapticsEnabled"
        static let endConfirmationEnabled = "endConfirmationEnabled"
        static let pureBlackModeEnabled = "pureBlackModeEnabled"
        static let remindersEnabled = "remindersEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
    }

    static let defaults = UserSettings(
        keepScreenAwake: true,
        hapticsEnabled: true,
        endConfirmationEnabled: true,
        pureBlackModeEnabled: true,
        remindersEnabled: false,
        reminderHour: defaultReminderHour,
        reminderMinute: defaultReminderMinute
    )

    static func normalizedReminderHour(_ hour: Int) -> Int {
        min(max(hour, 0), 23)
    }

    static func normalizedReminderMinute(_ minute: Int) -> Int {
        min(max(minute, 0), 59)
    }

    static func reminderTimeDate(
        hour: Int,
        minute: Int,
        calendar: Calendar = .current
    ) -> Date {
        let normalizedHour = normalizedReminderHour(hour)
        let normalizedMinute = normalizedReminderMinute(minute)

        return calendar.date(
            bySettingHour: normalizedHour,
            minute: normalizedMinute,
            second: 0,
            of: Date()
        ) ?? Date()
    }
}
