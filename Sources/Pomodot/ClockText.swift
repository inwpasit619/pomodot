import Foundation

extension Date {
    /// An Expected finish as the Mac shows clock times (12- or 24-hour), without seconds.
    var clockText: String {
        formatted(date: .omitted, time: .shortened)
    }
}
