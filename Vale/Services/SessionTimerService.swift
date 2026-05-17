import Foundation
import Observation

@Observable
final class SessionTimerService {
    private(set) var startDate: Date?
    private(set) var endDate: Date?
    private(set) var plannedDuration: TimeInterval = 0
    private(set) var intent: SessionIntent?
    private(set) var remainingTime: TimeInterval = 0

    var isActive: Bool {
        startDate != nil && endDate != nil
    }

    func start(duration: TimeInterval, intent: SessionIntent?, at now: Date = Date()) {
        let scheduledDuration = max(0, duration)
        startDate = now
        endDate = now.addingTimeInterval(scheduledDuration)
        plannedDuration = scheduledDuration
        self.intent = intent
        refresh(now: now)
    }

    @discardableResult
    func refresh(now: Date = Date()) -> TimeInterval {
        remainingTime = remainingDuration(at: now)
        return remainingTime
    }

    func remainingDuration(at date: Date = Date()) -> TimeInterval {
        guard let endDate else { return 0 }
        return max(0, endDate.timeIntervalSince(date))
    }

    func hasEnded(at date: Date = Date()) -> Bool {
        guard let endDate else { return false }
        return date >= endDate
    }

    func finish(completed: Bool, at date: Date = Date()) -> DetoxSession? {
        guard let startDate, let endDate else { return nil }

        let actualEndDate = completed ? endDate : date
        let elapsed = actualEndDate.timeIntervalSince(startDate)
        let actualDuration = completed
            ? plannedDuration
            : min(max(0, elapsed), plannedDuration)

        let session = DetoxSession(
            startDate: startDate,
            endDate: actualEndDate,
            plannedDuration: plannedDuration,
            actualDuration: actualDuration,
            completed: completed,
            intent: intent
        )

        reset()
        return session
    }

    func reset() {
        startDate = nil
        endDate = nil
        plannedDuration = 0
        intent = nil
        remainingTime = 0
    }
}
