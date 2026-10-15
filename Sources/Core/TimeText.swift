import Foundation

public enum TimeText {
    /// Time left as mm:ss, even past an hour: 90 minutes reads 90:00.
    public static func minutesSeconds(_ seconds: Int) -> String {
        let seconds = max(seconds, 0)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
