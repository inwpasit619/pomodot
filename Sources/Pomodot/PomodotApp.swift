import SwiftUI

@main
struct PomodotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Pomodot", systemImage: "timer") {
            MenuContent(model: appDelegate.model)
        }
        .menuBarExtraStyle(.menu)
    }
}

private struct MenuContent: View {
    @Bindable var model: AppModel

    var body: some View {
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
