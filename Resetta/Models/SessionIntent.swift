import Foundation

enum SessionIntent: String, Codable, CaseIterable, Identifiable, Hashable {
    case think = "Think"
    case rest = "Rest"
    case breathe = "Breathe"
    case walk = "Walk"
    case journal = "Journal"
    case doNothing = "Do nothing"

    var id: String { rawValue }
}
