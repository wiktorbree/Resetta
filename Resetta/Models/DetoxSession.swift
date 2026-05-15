import Foundation
import SwiftData

@Model
final class DetoxSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var plannedDuration: TimeInterval
    var actualDuration: TimeInterval
    var completed: Bool
    var intentRawValue: String?
    var feelingRawValue: String?
    var note: String?
    var createdAt: Date

    var intent: SessionIntent? {
        get {
            guard let intentRawValue else { return nil }
            return SessionIntent(rawValue: intentRawValue)
        }
        set {
            intentRawValue = newValue?.rawValue
        }
    }

    var feeling: SessionFeeling? {
        get {
            guard let feelingRawValue else { return nil }
            return SessionFeeling(rawValue: feelingRawValue)
        }
        set {
            feelingRawValue = newValue?.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval,
        completed: Bool,
        intent: SessionIntent? = nil,
        feeling: SessionFeeling? = nil,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.completed = completed
        self.intentRawValue = intent?.rawValue
        self.feelingRawValue = feeling?.rawValue
        self.note = note
        self.createdAt = createdAt
    }
}
