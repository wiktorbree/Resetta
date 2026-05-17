import SwiftUI
import UIKit

enum ValeTheme {
    static let primaryAccent = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.694, green: 0.659, blue: 0.604, alpha: 1)
        }

        return UIColor(red: 0.635, green: 0.584, blue: 0.529, alpha: 1)
    })
    static let secondaryAccent = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.784, green: 0.753, blue: 0.71, alpha: 1)
        }

        return UIColor(red: 0.694, green: 0.659, blue: 0.604, alpha: 1)
    })
    static let softHighlight = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.847, green: 0.82, blue: 0.784, alpha: 1)
        }

        return UIColor(red: 0.784, green: 0.753, blue: 0.71, alpha: 1)
    })
    static let accent = primaryAccent
    static let accentText = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.784, green: 0.753, blue: 0.71, alpha: 1)
        }

        return UIColor(red: 0.478, green: 0.431, blue: 0.384, alpha: 1)
    })
    static let accentForeground = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.122, green: 0.11, blue: 0.098, alpha: 1)
        }

        return UIColor(red: 0.122, green: 0.11, blue: 0.098, alpha: 1)
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
            return UIColor(white: 1, alpha: 0.055)
        }

        return UIColor(white: 0, alpha: 0.04)
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
            .foregroundStyle(ValeTheme.accentForeground.opacity(isEnabled ? 1 : 0.64))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 58)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 50, style: .continuous)
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
            .foregroundStyle(isSelected ? ValeTheme.accentForeground : Color.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 58)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(isSelected ? ValeTheme.accent : ValeTheme.quietFill.opacity(0.72))
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
            .background(ValeTheme.quietFill.opacity(configuration.isPressed ? 0.9 : 0.72), in: Circle())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}
