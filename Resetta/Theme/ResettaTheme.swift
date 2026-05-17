import SwiftUI
import UIKit

enum ResettaTheme {
    static let accent = Color(red: 0.24, green: 0.38, blue: 0.51)
    static let accentText = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.58, green: 0.76, blue: 0.90, alpha: 1)
        }

        return UIColor(red: 0.24, green: 0.38, blue: 0.51, alpha: 1)
    })
    static let softText = Color.secondary
    static let quietFill = Color(.secondarySystemBackground)
    static let subtleLine = Color(.separator).opacity(0.35)

    static func activeBackground(pureBlack: Bool) -> Color {
        pureBlack ? .black : Color(red: 0.025, green: 0.026, blue: 0.028)
    }
}
