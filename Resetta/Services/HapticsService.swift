import UIKit

@MainActor
enum HapticsService {
    static func sessionStarted(enabled: Bool) {
        subtleImpact(enabled: enabled, intensity: 0.46)
    }

    static func endSessionButtonRevealed(enabled: Bool) {
        subtleImpact(enabled: enabled, intensity: 0.42)
    }

    static func sessionCompleted(enabled: Bool) {
        subtleImpact(enabled: enabled, intensity: 0.54)
    }

    static func lightImpact(enabled: Bool) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func selection(enabled: Bool) {
        guard enabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType, enabled: Bool) {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    private static func subtleImpact(enabled: Bool, intensity: CGFloat) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}
