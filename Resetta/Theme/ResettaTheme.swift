import SwiftUI

enum ResettaTheme {
    static let accent = Color(red: 0.29, green: 0.44, blue: 0.58)
    static let softText = Color.secondary
    static let quietFill = Color(.secondarySystemBackground)
    static let subtleLine = Color(.separator).opacity(0.35)

    static func activeBackground(pureBlack: Bool) -> Color {
        pureBlack ? .black : Color(red: 0.025, green: 0.026, blue: 0.028)
    }
}
