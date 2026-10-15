import Observation

/// The one app-wide model the menu bar and the Floating Window share.
/// Timer state lives here, never in a window's view, because the user can hide the window.
@MainActor
@Observable
final class AppModel {}
