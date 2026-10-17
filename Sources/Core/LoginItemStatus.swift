/// What macOS says about opening Pomodot at login: the App reads it from ServiceManagement
/// each time, and it is never saved in a file.
public enum LoginItemStatus: Sendable, Equatable {
    case enabled
    /// Was registered once, then unregistered.
    case notRegistered
    /// Never registered: what a fresh install reports.
    case notFound
    /// Registered, but waiting for the user to allow it in System Settings.
    case requiresApproval

    /// Settings' Open at login switch.
    public var isOn: Bool {
        switch self {
        case .enabled, .requiresApproval: true
        case .notRegistered, .notFound: false
        }
    }

    /// The orange line under the switch, with its Open Login Items… button.
    public var needsApproval: Bool { self == .requiresApproval }
}
