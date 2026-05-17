import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    static let dailyReminderIdentifier = "vale.dailyReminder"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        let status = await authorizationStatus()

        switch status {
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                #if DEBUG
                print("Failed to request notification authorization: \(error)")
                #endif
                return false
            }
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func isAuthorizedForReminders() async -> Bool {
        Self.isAllowed(await authorizationStatus())
    }

    func synchronizeDailyReminder(
        enabled: Bool,
        hour: Int = UserSettings.defaultReminderHour,
        minute: Int = UserSettings.defaultReminderMinute,
        requestPermissionIfNeeded: Bool
    ) async -> DailyReminderSyncResult {
        guard enabled else {
            await cancelDailyReminder()
            return .disabled
        }

        let isAllowed = requestPermissionIfNeeded
            ? await requestAuthorizationIfNeeded()
            : await isAuthorizedForReminders()

        guard isAllowed else {
            await cancelDailyReminder()
            return await authorizationFailureResult()
        }

        do {
            try await scheduleDailyReminder(hour: hour, minute: minute)
            return .scheduled
        } catch {
            #if DEBUG
            print("Failed to schedule daily reminder: \(error)")
            #endif
            await cancelDailyReminder()
            return .schedulingFailed
        }
    }

    func scheduleDailyReminder(
        hour: Int = UserSettings.defaultReminderHour,
        minute: Int = UserSettings.defaultReminderMinute
    ) async throws {
        guard await isAuthorizedForReminders() else {
            throw NotificationServiceError.permissionDenied
        }

        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Vale"
        content.body = "Time for your daily reset."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = UserSettings.normalizedReminderHour(hour)
        dateComponents.minute = UserSettings.normalizedReminderMinute(minute)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
        await printPendingNotificationRequests()
    }

    func rescheduleDailyReminder(hour: Int, minute: Int) async throws {
        try await scheduleDailyReminder(hour: hour, minute: minute)
    }

    func cancelDailyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderIdentifier])
        await printPendingNotificationRequests()
    }

    private func authorizationFailureResult() async -> DailyReminderSyncResult {
        switch await authorizationStatus() {
        case .denied:
            return .permissionDenied
        case .notDetermined:
            return .permissionNotDetermined
        default:
            return .permissionDenied
        }
    }

    private static func isAllowed(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }

    private func printPendingNotificationRequests() async {
        #if DEBUG
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests.map(\.identifier).joined(separator: ", ")
        print("Pending notification requests: [\(identifiers)]")
        #endif
    }
}

enum DailyReminderSyncResult: Equatable {
    case disabled
    case scheduled
    case permissionDenied
    case permissionNotDetermined
    case schedulingFailed
}

enum NotificationServiceError: Error {
    case permissionDenied
}
