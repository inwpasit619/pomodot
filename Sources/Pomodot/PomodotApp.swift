import Core
import SwiftUI

@main
struct PomodotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuContent(model: appDelegate.model)
        } label: {
            MenuBarLabel(model: appDelegate.model)
        }
        .menuBarExtraStyle(.menu)
    }
}

/// The menu bar icon (a one-colour SF Symbol) and the time left.
/// Ready shows only the waiting Phase's icon; Paused shows `pause.circle` and a faded time.
private struct MenuBarLabel: View {
    let model: AppModel

    var body: some View {
        let timer = model.timer
        let time = TimeText.minutesSeconds(model.remainingSeconds)
        switch timer.status {
        case .ready:
            MenuBarImage(symbol: timer.phase.menuBarSymbol, time: nil, faded: false)
        case .running:
            MenuBarImage(symbol: timer.phase.menuBarSymbol, time: time, faded: false)
        case .paused:
            MenuBarImage(symbol: "pause.circle", time: time, faded: true)
        }
    }
}

/// Draws the icon and time into one template image. A MenuBarExtra label drops
/// opacity and colour, so a faded time is only possible as alpha inside an image;
/// as a template, macOS still tints it to match the menu bar like Wi-Fi or battery.
private struct MenuBarImage: View {
    let symbol: String
    let time: String?
    let faded: Bool

    var body: some View {
        Image(nsImage: render())
            .accessibilityLabel(time ?? "Pomodot")
    }

    private func render() -> NSImage {
        let font = Font.system(size: NSFont.menuBarFont(ofSize: 0).pointSize)
        let content = HStack(spacing: 4) {
            Image(systemName: symbol)
            if let time {
                Text(time)
                    .monospacedDigit()
                    .opacity(faded ? 0.5 : 1)
            }
        }
        .font(font)
        .foregroundStyle(.black)

        let renderer = ImageRenderer(content: content)
        renderer.scale = NSScreen.screens.first?.backingScaleFactor ?? 2
        let image = renderer.nsImage ?? NSImage()
        image.isTemplate = true
        return image
    }
}

private struct MenuContent: View {
    @Bindable var model: AppModel

    var body: some View {
        Button(model.timer.status.startPauseResumeTitle) {
            model.startPauseResume()
        }
        Button("Skip") {
            model.skip()
        }
        Button("Reset…") {
            ConfirmationAlert.ask(model.timer.resetConfirmation, then: model.reset)
        }
        Button("New Cycle…") {
            ConfirmationAlert.ask(model.timer.newCycleConfirmation, then: model.newCycle)
        }

        Divider()

        Button(model.isFloatingWindowVisible ? "Hide Floating Window" : "Show Floating Window") {
            model.isFloatingWindowVisible.toggle()
        }
        Toggle("Always on Top", isOn: $model.isAlwaysOnTop)

        Divider()

        Button("Quit Pomodot") {
            NSApp.terminate(nil)
        }
    }
}
