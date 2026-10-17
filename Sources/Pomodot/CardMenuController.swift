import AppKit
import Core

/// The card's menu, from its ellipsis button or a right-click on the capsule or card:
/// one `NSMenu` whose items are rebuilt from Core each time it opens.
/// Opening it doesn't activate Pomodot, so the app the user is typing in keeps the keyboard.
@MainActor
final class CardMenuController: NSObject, NSMenuDelegate {
    let menu = NSMenu()
    /// Called as the menu opens and closes, so the card stays open meanwhile.
    var onOpen: (() -> Void)?
    var onClose: (() -> Void)?

    private let model: AppModel
    /// Opens the windows and pages the menu leads to.
    private weak var app: AppDelegate?

    init(model: AppModel, app: AppDelegate) {
        self.model = model
        self.app = app
        super.init()
        // Otherwise AppKit enables every item with a target and ignores `isEnabled`.
        menu.autoenablesItems = false
        menu.delegate = self
    }

    /// The items for `place`, as Core lists them.
    func items(for place: CardMenu.Place) -> [NSMenuItem] {
        let cardMenu = CardMenu(
            todayPomodoros: model.statistics.today.pomodoros,
            timer: model.timer,
            isFloatingWindowVisible: model.isFloatingWindowVisible,
            isAlwaysOnTop: model.isAlwaysOnTop
        )
        return cardMenu.entries(for: place).map { entry in
            switch entry {
            case .separator:
                return .separator()
            case .item(let item):
                let menuItem = NSMenuItem(title: item.title, action: nil, keyEquivalent: "")
                if let command = item.command {
                    menuItem.target = self
                    menuItem.action = #selector(choose(_:))
                    menuItem.representedObject = command
                }
                menuItem.isEnabled = item.isEnabled
                menuItem.state = item.isChecked ? .on : .off
                return menuItem
            }
        }
    }

    /// The Dock icon's menu: the same items without Quit Pomodot, made afresh each time macOS asks.
    /// It has no delegate: opening it never holds the card open.
    func dockMenu() -> NSMenu {
        let dockMenu = NSMenu()
        dockMenu.autoenablesItems = false
        dockMenu.items = items(for: .dock)
        return dockMenu
    }

    // MARK: NSMenuDelegate

    /// Items change only here: AppKit asks just before the menu opens.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.items = items(for: .card)
    }

    func menuWillOpen(_ menu: NSMenu) {
        onOpen?()
    }

    /// Comes before the chosen item's action runs.
    func menuDidClose(_ menu: NSMenu) {
        onClose?()
    }

    // MARK: Commands

    @objc private func choose(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? CardMenu.Command else { return }
        run(command)
    }

    /// Does what the menu bar's item of the same name does.
    func run(_ command: CardMenu.Command) {
        switch command {
        case .newCycle:
            ConfirmationAlert.ask(model.timer.newCycleConfirmation, then: model.newCycle)
        case .hideOrShowFloatingWindow:
            model.isFloatingWindowVisible.toggle()
        case .alwaysOnTop:
            model.isAlwaysOnTop.toggle()
        case .statistics:
            app?.showStatistics()
        case .settings:
            app?.showSettings()
        case .about:
            app?.showAbout()
        case .checkForUpdates:
            app?.checkForUpdates()
        case .quit:
            // No question: Pomodot comes back Paused where it was.
            NSApp.terminate(nil)
        }
    }
}
