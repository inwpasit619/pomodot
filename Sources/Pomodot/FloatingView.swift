import AppKit
import Core
import SwiftUI

/// The Floating Window's content: the collapsed capsule (Phase dot, time left, READY / PAUSED).
struct FloatingView: View {
    let model: AppModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let timer = model.timer
        let color = PhaseColor.of(timer.phase)
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
                // A soft glow while Running.
                .shadow(color: timer.status == .running ? color.opacity(0.9) : .clear, radius: 3.5)
            Text(TimeText.minutesSeconds(model.remainingSeconds))
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
            if let label = timer.status.capsuleLabel {
                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.4)
                    .opacity(0.55)
            }
        }
        .foregroundStyle(colorScheme == .dark ? Glass.darkText : Glass.lightText)
        // A fixed size: a hosting view that sizes itself to its content
        // crashes Auto Layout when the text changes.
        .frame(
            width: FloatingWindowPlacement.capsuleSize.width,
            height: FloatingWindowPlacement.capsuleSize.height
        )
        .background {
            GlassBackground()
                .overlay(colorScheme == .dark ? Glass.darkTint : Glass.lightTint)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(.primary.opacity(0.08), lineWidth: 0.5))
        }
    }
}

/// The glass colours from the chosen prototype.
private enum Glass {
    static let lightTint = Color(red: 248 / 255, green: 248 / 255, blue: 250 / 255).opacity(0.62)
    static let darkTint = Color(red: 38 / 255, green: 38 / 255, blue: 42 / 255).opacity(0.55)
    static let lightText = Color(red: 0x1D / 255, green: 0x1D / 255, blue: 0x1F / 255)
    static let darkText = Color(red: 0xF5 / 255, green: 0xF5 / 255, blue: 0xF7 / 255)
}

/// Blurs whatever is behind the window, following Light / Dark.
private struct GlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        // Pomodot is almost never the active app; the default state would draw flat grey.
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
