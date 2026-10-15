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
    let model: AppModel

    var body: some View {
        Button("Quit Pomodot") {
            NSApp.terminate(nil)
        }
    }
}
