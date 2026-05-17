import SwiftUI
import UIKit

enum ValeTheme {
    static let accent = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.42, green: 0.57, blue: 0.68, alpha: 1)
        }

        return UIColor(red: 0.24, green: 0.38, blue: 0.51, alpha: 1)
    })
    static let accentText = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.68, green: 0.80, blue: 0.88, alpha: 1)
        }

        return UIColor(red: 0.24, green: 0.38, blue: 0.51, alpha: 1)
    })
    static let screenBackground = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.045, green: 0.047, blue: 0.052, alpha: 1)
        }

        return UIColor(red: 0.982, green: 0.979, blue: 0.965, alpha: 1)
    })
    static let surface = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.082, green: 0.086, blue: 0.094, alpha: 1)
        }

        return UIColor(red: 1, green: 0.998, blue: 0.99, alpha: 1)
    })
    static let softText = Color.secondary
    static let quietFill = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.12, green: 0.125, blue: 0.135, alpha: 1)
        }

        return UIColor(red: 0.943, green: 0.941, blue: 0.925, alpha: 1)
    })
    static let subtleLine = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(white: 1, alpha: 0.11)
        }

        return UIColor(white: 0, alpha: 0.08)
    })

    static func activeBackground(pureBlack: Bool) -> Color {
        pureBlack ? .black : Color(red: 0.025, green: 0.026, blue: 0.028)
    }

    static func horizontalPadding(for width: CGFloat) -> CGFloat {
        if width < 380 {
            return 22
        }

        if width > 700 {
            return 48
        }

        return 28
    }

    static func contentWidth(for width: CGFloat) -> CGFloat {
        min(width, 560)
    }

    static func calmAnimation(reduceMotion: Bool, duration: Double = 0.28) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration)
    }

    static var calmTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.985))
    }
}

struct ValePrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 58)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ValeTheme.accent.opacity(isEnabled ? 1 : 0.36))
            }
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.985 : 1))
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct ValeQuietButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var foregroundStyle = AnyShapeStyle(Color.primary)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(foregroundStyle)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ValeTheme.quietFill.opacity(configuration.isPressed ? 0.64 : 0))
            }
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct ValeOptionButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 58)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(isSelected ? ValeTheme.accent : ValeTheme.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(isSelected ? ValeTheme.accent.opacity(0.42) : ValeTheme.subtleLine, lineWidth: 1)
            }
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.985 : 1))
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ValeIconButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(width: 46, height: 46)
            .background(ValeTheme.surface, in: Circle())
            .overlay {
                Circle()
                    .stroke(ValeTheme.subtleLine, lineWidth: 1)
            }
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}
