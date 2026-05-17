import Foundation

enum SessionFeeling: String, Codable, CaseIterable, Identifiable, Hashable {
    case calm = "Calm"
    case restless = "Restless"
    case clear = "Clear"
    case difficult = "Difficult"

    var id: String { rawValue }
}
