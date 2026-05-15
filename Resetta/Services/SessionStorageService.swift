import Foundation
import Observation
import SwiftData

@Observable
final class SessionStorageService {
    private(set) var lastError: String?

    func save(_ session: DetoxSession, in context: ModelContext) {
        context.insert(session)
        commit(context)
    }

    func updateReflection(
        for session: DetoxSession,
        feeling: SessionFeeling?,
        note: String,
        in context: ModelContext
    ) {
        session.feeling = feeling
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        session.note = trimmedNote.isEmpty ? nil : trimmedNote
        commit(context)
    }

    private func commit(_ context: ModelContext) {
        do {
            try context.save()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }
}
