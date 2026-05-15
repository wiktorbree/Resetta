import Foundation

enum TimeFormatting {
    static func countdown(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(interval)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    static func duration(_ interval: TimeInterval) -> String {
        let totalMinutes = max(0, Int(round(interval / 60)))

        if totalMinutes < 1 {
            let seconds = max(0, Int(round(interval)))
            return "\(seconds) sec"
        }

        if totalMinutes == 1 {
            return "1 min"
        }

        return "\(totalMinutes) min"
    }

    static func clockTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
