import Observation

/// The one app-wide model the menu bar and the Floating Window share.
/// Timer state lives here, never in a window's view, because the user can hide the window.
@MainActor
@Observable
final class AppModel {
    /// Shown on first launch. Not remembered across launches yet.
    var isFloatingWindowVisible = true
    /// On by default. Not remembered across launches yet.
    var isAlwaysOnTop = true
}
