import SwiftData
import SwiftUI

struct SessionFlowView: View {
    let duration: TimeInterval

    @AppStorage("hapticsEnabled") private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SessionStorageService.self) private var storage
    @Environment(SessionTimerService.self) private var timer
    @State private var stage: Stage = .intent
    @State private var savedSession: DetoxSession?

    var body: some View {
        Group {
            switch stage {
            case .intent:
                SessionIntentView(
                    duration: duration,
                    onStart: startSession(intent:),
                    onCancel: dismissFlow
                )
            case .active:
                ActiveSessionView(
                    onCompleted: { finishSession(completed: true) },
                    onEnded: { finishSession(completed: false) }
                )
            case .completion:
                if let savedSession {
                    CompletionView(
                        session: savedSession,
                        onReflect: {
                            stage = .reflection
                        },
                        onDone: dismissFlow
                    )
                }
            case .reflection:
                if let savedSession {
                    ReflectionView(
                        session: savedSession,
                        onSave: { feeling, note in
                            storage.updateReflection(
                                for: savedSession,
                                feeling: feeling,
                                note: note,
                                in: modelContext
                            )
                            dismissFlow()
                        }
                    )
                }
            }
        }
        .interactiveDismissDisabled(stage == .active)
        .animation(.easeInOut(duration: 0.2), value: stage)
    }

    private func startSession(intent: SessionIntent?) {
        timer.start(duration: duration, intent: intent)
        HapticsService.lightImpact(enabled: hapticsEnabled)
        stage = .active
    }

    private func finishSession(completed: Bool) {
        guard let session = timer.finish(completed: completed) else {
            dismissFlow()
            return
        }

        storage.save(session, in: modelContext)
        savedSession = session
        HapticsService.notification(completed ? .success : .warning, enabled: hapticsEnabled)
        stage = .completion
    }

    private func dismissFlow() {
        timer.reset()
        OrientationService.shared.lockPortrait()
        dismiss()
    }
}

private enum Stage {
    case intent
    case active
    case completion
    case reflection
}

#Preview {
    SessionFlowView(duration: 5 * 60)
        .environment(SessionTimerService())
        .environment(SessionStorageService())
        .modelContainer(for: DetoxSession.self, inMemory: true)
}
