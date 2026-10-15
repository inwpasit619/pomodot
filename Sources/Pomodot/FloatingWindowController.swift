import AppKit
import Core
import SwiftUI

/// A borderless panel that floats over every app, full-screen ones included,
/// and never activates Pomodot when clicked.
final class FloatingPanel: NSPanel {
    // A borderless panel can't receive clicks on its buttons unless it can become key.
    override var canBecomeKey: Bool { true }
}

/// Owns the Floating Window and keeps it in step with the app model.
@MainActor
final class FloatingWindowController {
    private let model: AppModel
    private let panel: FloatingPanel

    init(model: AppModel) {
        self.model = model

        // The primary display (the one with the menu bar), not NSScreen.main:
        // .main follows the key window, and this app never activates.
        let visibleFrame = NSScreen.screens.first?.visibleFrame ?? .zero
        panel = FloatingPanel(
            contentRect: FloatingWindowPlacement.startingCapsuleFrame(in: visibleFrame),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .canJoinAllApplications]
        // NSPanel defaults to true, which would hide it whenever Pomodot isn't active.
        panel.hidesOnDeactivate = false
        // A click on the capsule must not take the keyboard from the app the user is typing in.
        panel.becomesKeyOnlyIfNeeded = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        // Simple drag for now; the real drag rules replace this in M2.
        panel.isMovableByWindowBackground = true
        panel.contentView = NSHostingView(rootView: FloatingView(model: model))

        apply()
    }

    /// Applies the model to the panel, then waits for the next change.
    private func apply() {
        withObservationTracking {
            panel.level = model.isAlwaysOnTop ? .floating : .normal
            if model.isFloatingWindowVisible {
                // Shows the panel without activating the app.
                panel.orderFrontRegardless()
            } else {
                panel.orderOut(nil)
            }
        } onChange: { [weak self] in
            // Called before the change lands, so read the new values on the next turn.
            Task { @MainActor in self?.apply() }
        }
    }
}
