import AppKit
import Core
import SwiftUI

/// The Floating Window's content: the capsule, which opens into the card.
/// The glass box grows from the capsule's corner, so the capsule never moves.
/// The panel doesn't change size; the box moves and resizes inside it.
struct FloatingView: View {
    /// The view's own coordinates (top-left origin), where the card's buttons report their frames.
    static let coordinateSpaceName = "FloatingView"

    let model: AppModel
    let display: FloatingWindowDisplay

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let expanded = display.isExpanded
        let box = display.boxFrame
        let shape = RoundedRectangle(cornerRadius: expanded ? 18 : box.height / 2, style: .continuous)
        // The widened capsule keeps its contents in the middle.
        let anchor = display.isHovered ? .center : display.cardLayout?.anchor ?? .center
        let bounces = !reduceMotion
        let swap: AnyTransition = reduceMotion ? .identity : .contentSwap(from: display.cardLayout?.unitAnchor ?? .center)

        ZStack(alignment: anchor) {
            if expanded {
                FloatingCard(model: model)
                    .transition(swap)
            } else {
                FloatingCapsule(model: model)
                    .transition(swap)
            }
        }
        .foregroundStyle(colorScheme == .dark ? Glass.darkText : Glass.lightText)
        // Fixed sizes: a hosting view that sizes itself to its content
        // crashes Auto Layout when the text changes.
        .frame(width: box.width, height: box.height, alignment: anchor)
        .clipShape(shape)
        .background {
            GlassBackground()
                .overlay(colorScheme == .dark ? Glass.darkTint : Glass.lightTint)
                .clipShape(shape)
                .overlay(shape.strokeBorder(.primary.opacity(0.08), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        }
        // One soft bounce when the Phase changes; the colours ease across.
        .keyframeAnimator(initialValue: 1.0, trigger: model.timer.phase) { content, scale in
            content.scaleEffect(bounces ? scale : 1)
        } keyframes: { _ in
            SpringKeyframe(1.045, duration: 0.25)
            SpringKeyframe(1.0, duration: 0.45)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.7), value: model.timer.phase)
        .offset(x: box.minX, y: box.minY)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .coordinateSpace(.named(Self.coordinateSpaceName))
        .onPreferenceChange(ButtonFramesKey.self) { frames in
            MainActor.assumeIsolated { display.buttonFrames = frames }
        }
    }
}

/// Collapsed: Phase dot, time left, READY / PAUSED.
private struct FloatingCapsule: View {
    let model: AppModel

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
                .breathing(timer.status == .paused)
            if let label = timer.status.capsuleLabel {
                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.4)
                    .opacity(0.55)
            }
        }
        .frame(
            width: FloatingWindowPlacement.capsuleSize.width,
            height: FloatingWindowPlacement.capsuleSize.height
        )
    }
}

/// Expanded: every control the Floating Window has, and no others.
private struct FloatingCard: View {
    let model: AppModel

    var body: some View {
        let timer = model.timer
        let color = PhaseColor.of(timer.phase)
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                PhaseChip(phase: timer.phase, color: color)
                ProgressDots(done: timer.pomodorosDone, total: timer.pomodorosPerCycle, color: color)
                Text("\(timer.displayNumber)/\(timer.pomodorosPerCycle)")
                    .font(.system(size: 11))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button {
                    model.isFloatingWindowVisible = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                }
                .buttonStyle(RoundButtonStyle())
                .help("Hide Floating Window")
                .accessibilityLabel("Hide Floating Window")
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(TimeText.minutesSeconds(model.remainingSeconds))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .breathing(timer.status == .paused)
                if let label = timer.status.capsuleLabel {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 8)

            TimeLeftBar(fraction: timer.fractionLeft(at: model.now), color: color)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Button {
                    model.startPauseResume()
                } label: {
                    Label(timer.status.startPauseResumeTitle,
                          systemImage: timer.status == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(color: color))

                Button {
                    ConfirmationAlert.ask(model.timer.resetConfirmation, then: model.reset)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(SquareButtonStyle())
                .help("Reset")
                .accessibilityLabel("Reset")

                Button {
                    model.skip()
                } label: {
                    Image(systemName: "forward.end.fill")
                }
                .buttonStyle(SquareButtonStyle())
                .help("Skip")
                .accessibilityLabel("Skip")
            }
        }
        .padding(EdgeInsets(top: 12, leading: 14, bottom: 14, trailing: 14))
        .frame(
            width: FloatingWindowPlacement.cardSize.width,
            height: FloatingWindowPlacement.cardSize.height
        )
    }
}

private struct PhaseChip: View {
    let phase: Phase
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(phase.name)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 9))
        .background(color.opacity(0.15), in: Capsule())
    }
}

/// N dots for the Cycle, the first `done` filled.
private struct ProgressDots: View {
    let done: Int
    let total: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < done ? AnyShapeStyle(color) : AnyShapeStyle(.primary.opacity(0.12)))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

/// Time left against the Phase's full length.
private struct TimeLeftBar: View {
    let fraction: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(.primary.opacity(0.1))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * fraction)
                }
        }
        .frame(height: 6)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .frame(height: 34)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1),
                         in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
            .reportsButtonFrame()
    }
}

private struct SquareButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .frame(width: 34, height: 34)
            .background(.primary.opacity(configuration.isPressed ? 0.16 : 0.08),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
            .reportsButtonFrame()
    }
}

private struct RoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(.primary.opacity(configuration.isPressed ? 0.16 : 0.08), in: Circle())
            .contentShape(Circle())
            .reportsButtonFrame()
    }
}

/// The frames of the card's buttons, so the window knows a press there is not a drag.
private struct ButtonFramesKey: PreferenceKey {
    static let defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value += nextValue()
    }
}

private extension View {
    func reportsButtonFrame() -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(key: ButtonFramesKey.self,
                                       value: [proxy.frame(in: .named(FloatingView.coordinateSpaceName))])
            }
        }
    }

    /// Paused: the time fades out and back in, like breathing. Off with Reduce Motion.
    func breathing(_ active: Bool) -> some View {
        modifier(Breathing(active: active))
    }
}

private struct Breathing: ViewModifier {
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if active, !reduceMotion {
            content.phaseAnimator([1.0, 0.38]) { content, opacity in
                content.opacity(opacity)
            } animation: { _ in
                .easeInOut(duration: 1.2)
            }
        } else {
            content
        }
    }
}

/// How the capsule's and the card's contents swap while the glass grows or shrinks:
/// the old contents fade out quickly, then the new ones fade and sharpen in, so the
/// two never show on top of each other.
private extension AnyTransition {
    static func contentSwap(from anchor: UnitPoint) -> AnyTransition {
        let hidden = SoftlyHidden(amount: 1, anchor: anchor)
        let shown = SoftlyHidden(amount: 0, anchor: anchor)
        return .asymmetric(
            insertion: .modifier(active: hidden, identity: shown)
                .animation(.smooth(duration: 0.26).delay(0.1)),
            removal: .modifier(active: hidden, identity: shown)
                .animation(.easeOut(duration: 0.1))
        )
    }
}

/// Faded, slightly blurred and slightly smaller as `amount` goes from 0 to 1.
private struct SoftlyHidden: ViewModifier {
    let amount: Double
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content
            .opacity(1 - amount)
            .blur(radius: 4 * amount)
            .scaleEffect(1 - 0.04 * amount, anchor: anchor)
    }
}

extension CardLayout {
    /// `anchor` as a point, for scaling from the same corner or edge.
    var unitAnchor: UnitPoint {
        let a = anchor
        let x: CGFloat = a.horizontal == .leading ? 0 : a.horizontal == .trailing ? 1 : 0.5
        let y: CGFloat = a.vertical == .top ? 0 : a.vertical == .bottom ? 1 : 0.5
        return UnitPoint(x: x, y: y)
    }

    /// Where the capsule sits inside the card: the corner or edge the card grows from.
    var anchor: Alignment {
        let vertical: VerticalAlignment = self.vertical == .down ? .top : .bottom
        let horizontal: HorizontalAlignment = switch self.horizontal {
        case .centered: .center
        case .rightEdges: .trailing
        case .leftEdges: .leading
        }
        return Alignment(horizontal: horizontal, vertical: vertical)
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
