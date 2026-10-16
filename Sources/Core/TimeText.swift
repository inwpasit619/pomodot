import Foundation

public enum TimeText {
    /// Time left as mm:ss, even past an hour: 90 minutes reads 90:00.
    public static func minutesSeconds(_ seconds: Int) -> String {
        let seconds = max(seconds, 0)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    /// Total Focus time as Statistics writes it: 2h 05m, or 45m under an hour.
    public static func hoursMinutes(_ seconds: Int) -> String {
        let minutes = max(seconds, 0) / 60
        guard minutes >= 60 else { return "\(minutes)m" }
        return String(format: "%dh %02dm", minutes / 60, minutes % 60)
    }
}
