import Foundation
import Testing
import Core

/// The card's menu with the Floating Window showing and Always on Top on, unless a test says otherwise.
private func menu(
    today: Int = 5,
    timer: PomodoroTimer = PomodoroTimer(),
    visible: Bool = true,
    alwaysOnTop: Bool = true
) -> CardMenu {
    CardMenu(todayPomodoros: today, timer: timer, isFloatingWindowVisible: visible, isAlwaysOnTop: alwaysOnTop)
}

private func item(_ title: String, in entries: [CardMenu.Entry]) -> CardMenu.Item? {
    for case let .item(item) in entries where item.title == title {
        return item
    }
    return nil
}

/// Titles in order, with "—" for each separator.
private func titles(_ entries: [CardMenu.Entry]) -> [String] {
    entries.map {
        switch $0 {
        case .item(let item): item.title
        case .separator: "—"
        }
    }
}

@Test("Given 5 Pomodoros today, when the card's menu opens, then it lists Today, New Cycle, Hide, Always on Top, Statistics, Settings, About, Check for Updates and Quit, in groups")
func cardMenuOrder() {
    // Given
    let menu = menu(today: 5)

    // When
    let entries = menu.entries(for: .card)

    // Then
    #expect(titles(entries) == [
        "Today: 🍅 5",
        "—",
        "New Cycle…",
        "—",
        "Hide Floating Window",
        "Always on Top",
        "—",
        "Statistics…",
        "Settings…",
        "—",
        "About Pomodot",
        "Check for Updates…",
        "—",
        "Quit Pomodot",
    ])
}

@Test("Given the card's menu, when it opens, then the Today line can't be chosen and runs nothing")
func todayLineIsDisabled() {
    // Given
    let menu = menu(today: 3)

    // When
    let today = item("Today: 🍅 3", in: menu.entries(for: .card))

    // Then
    #expect(today?.isEnabled == false)
    #expect(today?.command == nil)
}

@Test("Given the Floating Window is showing, when the menu opens, then it offers Hide Floating Window; given it is hidden, Show Floating Window")
func hideOrShowFollowsTheFloatingWindow() {
    // Given
    let showing = menu(visible: true)
    let hidden = menu(visible: false)

    // When
    let whileShowing = item("Hide Floating Window", in: showing.entries(for: .card))
    let whileHidden = item("Show Floating Window", in: hidden.entries(for: .dock))

    // Then
    #expect(whileShowing?.command == .hideOrShowFloatingWindow)
    #expect(whileHidden?.command == .hideOrShowFloatingWindow)
    #expect(item("Show Floating Window", in: showing.entries(for: .card)) == nil)
    #expect(item("Hide Floating Window", in: hidden.entries(for: .dock)) == nil)
}

@Test("Given Always on Top is on, when the menu opens, then Always on Top has a check mark; given it is off, it has none")
func alwaysOnTopCheckMark() {
    // Given
    let on = menu(alwaysOnTop: true)
    let off = menu(alwaysOnTop: false)

    // When
    let whileOn = item("Always on Top", in: on.entries(for: .card))
    let whileOff = item("Always on Top", in: off.entries(for: .card))

    // Then
    #expect(whileOn?.isChecked == true)
    #expect(whileOff?.isChecked == false)
    #expect(whileOn?.command == .alwaysOnTop)
}

@Test("Given Focus 1/4 Ready with no Pomodoro yet, when the menu opens, then New Cycle… can't be chosen; once a Focus has started, it can")
func newCycleGreyedOutWhenItWouldChangeNothing() {
    // Given
    var started = PomodoroTimer()
    started.start(at: at("09:00"))

    // When
    let fresh = item("New Cycle…", in: menu(timer: PomodoroTimer()).entries(for: .card))
    let afterStart = item("New Cycle…", in: menu(timer: started).entries(for: .card))

    // Then
    #expect(fresh?.isEnabled == false)
    #expect(afterStart?.isEnabled == true)
    #expect(afterStart?.command == .newCycle)
}

@Test("Given the same state, when the Dock's menu is built, then it is the card's menu without Quit Pomodot and the separator before it")
func dockMenuHasNoQuit() {
    // Given
    let menu = menu()

    // When
    let card = menu.entries(for: .card)
    let dock = menu.entries(for: .dock)

    // Then
    #expect(dock == Array(card.dropLast(2)))
    #expect(item("Quit Pomodot", in: dock) == nil)
}

@Test("Given the card's menu, when it opens, then every item but Today runs its own command")
func everyItemHasItsCommand() {
    // Given
    var started = PomodoroTimer()
    started.start(at: at("09:00"))
    let menu = menu(timer: started)

    // When
    let entries = menu.entries(for: .card)

    // Then
    #expect(item("Statistics…", in: entries)?.command == .statistics)
    #expect(item("Settings…", in: entries)?.command == .settings)
    #expect(item("About Pomodot", in: entries)?.command == .about)
    #expect(item("Check for Updates…", in: entries)?.command == .checkForUpdates)
    #expect(item("Quit Pomodot", in: entries)?.command == .quit)
}
