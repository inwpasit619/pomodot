import AppKit
import Core
import Observation

/// The one app-wide model the menu bar and the Floating Window share.
/// Timer state lives here, never in a window's view, because the user can hide the window.
/// The rules live in Core: this only feeds it button presses, sleep and ticks, with the clock.
@MainActor
@Observable
final class AppModel {
    /// Shown whenever Pomodot opens. Hidden from any menu, the first time ever it says how to
    /// bring it back.
    var isFloatingWindowVisible: Bool {
        didSet {
            if oldValue, !isFloatingWindowVisible,
               let notice = HideNotice.onHiding(alreadyShown: &hideNoticeShown, showInDock: hasDockIcon) {
                HideNoticeAlert.tell(notice)
            }
            saveState()
        }
    }
    /// The notice on the first Hide has been shown; remembered in state.json.
    @ObservationIgnored private var hideNoticeShown: Bool
    /// Pomodot shows in the Dock, so clicking its icon brings the Floating Window back.
    private var hasDockIcon: Bool { NSApp.activationPolicy() == .regular }
    /// On by default; remembered in state.json.
    var isAlwaysOnTop: Bool {
        didSet { saveState() }
    }
    /// The collapsed capsule's centre, set when it is dragged or macOS moves it. Nil until
    /// then: the Floating Window opens at the starting position.
    @ObservationIgnored var capsuleCenter: CGPoint? {
        didSet { saveState() }
    }
    /// Every value in the Settings window, remembered in settings.json. A change takes effect
    /// straight away by the timer's rules: a Phase that has started keeps its length to the end.
    var settings: Settings {
        didSet {
            guard settings != oldValue else { return }
            settingsFile.save(SettingsFile.encode(settings))
            if settings.appearance != oldValue.appearance {
                applyAppearance()
            }
            let timerSettings = Self.timerSettings(from: settings, focusMinutes: focusMinutesForThisRun)
            send { timer, _ in
                timer.apply(timerSettings)
                return TimerOutcome()
            }
        }
    }

    /// Off: no permission asked, no banners, but the sounds still play.
    var showNotifications: Bool { settings.showNotifications }

    /// macOS has turned Pomodot's notifications off. Checked when Settings opens and
    /// whenever Pomodot comes back active, e.g. from System Settings.
    private(set) var notificationsTurnedOffInSystemSettings = false

    /// The orange line under Show notifications in Settings.
    var warnsNotificationsAreOff: Bool {
        settings.warnsNotificationsAreOff(turnedOffInSystemSettings: notificationsTurnedOffInSystemSettings)
    }

    /// Open at login, as macOS says it is. Read when Settings opens and whenever Pomodot
    /// comes back active, e.g. from System Settings; never saved, so Restore Defaults leaves it alone.
    private(set) var loginItemStatus = LoginItem.status

    /// Each sound dropdown: None, then every system sound.
    let soundChoices = Settings.soundChoices(onThisMac: SoundPlayer.systemSoundNames)

    private(set) var timer: PomodoroTimer
    /// Every Pomodoro, loaded from history.json at launch.
    private(set) var history: History
    /// The clock time the views draw from. Each tick moves it on.
    private(set) var now = Date()

    /// Sends `tick` about once a second, only while Running.
    @ObservationIgnored private var ticker: Timer?
    /// Keeps macOS from delaying the ticks while Running; idle sleep still allowed.
    @ObservationIgnored private var activity: NSObjectProtocol?
    /// While not Running, moves `now` on when the Expected finish minute next changes.
    @ObservationIgnored private var clock: Timer?
    @ObservationIgnored private let historyFile = StoredFile(name: "history")
    @ObservationIgnored private let stateFile = StoredFile(name: "state")
    @ObservationIgnored private let settingsFile = StoredFile(name: "settings")
    /// A Focus length for this run only, from the launch arguments; never saved.
    @ObservationIgnored private let focusMinutesForThisRun = AppModel.focusMinutesFromLaunchArguments()
    /// While Running, state.json is saved at least this often, so a Force Quit loses no more.
    private static let saveInterval: TimeInterval = 30
    @ObservationIgnored private var lastStateSave = Date.distantPast
    @ObservationIgnored private let soundPlayer = SoundPlayer()
    @ObservationIgnored private let bannerNotifier = BannerNotifier()

    init() {
        history = historyFile.load(HistoryFile.decode)
        // Settings first: a fresh timer, and a Phase that never started, take their lengths.
        var settings = settingsFile.load(SettingsFile.decode)
        settings.replaceMissingSounds(onThisMac: SoundPlayer.systemSoundNames)
        self.settings = settings
        let timerSettings = Self.timerSettings(from: settings, focusMinutes: focusMinutesForThisRun)
        // Where the app was at the last Quit, Paused (or Ready if it hadn't started).
        let saved = stateFile.load { StateFile.decode($0, settings: timerSettings) }
        timer = PomodoroTimer(restoring: saved.timer, settings: timerSettings)
        // Always true: the capsule shows whenever Pomodot opens.
        isFloatingWindowVisible = saved.floatingWindow.visible
        hideNoticeShown = saved.floatingWindow.hideNoticeShown
        isAlwaysOnTop = saved.floatingWindow.alwaysOnTop
        capsuleCenter = saved.floatingWindow.center
        // Only real sleep (lid closed, Sleep chosen). Locking the screen, the display
        // going off and the screensaver send nothing: the timer keeps running.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.sleep() }
        }
        // Expected finish is "from now": after waking or a clock change, now is somewhere else.
        // Today starts at midnight, and days are cut in the Mac's time zone as it is now.
        let redrawNow: [(NotificationCenter, Notification.Name)] = [
            (NSWorkspace.shared.notificationCenter, NSWorkspace.didWakeNotification),
            (.default, .NSSystemClockDidChange),
            (.default, .NSCalendarDayChanged),
            (.default, .NSSystemTimeZoneDidChange),
        ]
        for (center, name) in redrawNow {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.update(Date()) }
            }
        }
        // Ready from launch: Expected finish already moves with the clock.
        scheduleClock()
        // Back from System Settings, perhaps with notifications allowed or turned off.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkWhetherNotificationsAreTurnedOff()
                self?.checkLoginItem()
            }
        }
        // Before any window shows, so none of them flashes in the other look.
        applyAppearance()
        // Clicking a banner brings the Floating Window back if it was hidden.
        bannerNotifier.onClick = { [weak self] in self?.isFloatingWindowVisible = true }
    }

    /// For manual tests that would otherwise wait 25 minutes, `open Pomodot.app --args
    /// -focusMinutes 1` shortens Focus for that run only, whatever Settings say; it is never
    /// written to settings.json. A normal launch never passes it.
    private static func focusMinutesFromLaunchArguments() -> Int? {
        let arguments = UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
        return (arguments["focusMinutes"] as? String).flatMap(Int.init).flatMap { $0 >= 1 ? $0 : nil }
    }

    /// What the timer runs on: Settings, with this run's Focus length if one was passed.
    private static func timerSettings(from settings: Settings, focusMinutes: Int?) -> TimerSettings {
        var timerSettings = settings.timer
        if let focusMinutes {
            timerSettings.focusMinutes = focusMinutes
        }
        return timerSettings
    }

    var remainingSeconds: Int { timer.remainingSeconds(at: now) }

    var expectedFinish: ExpectedFinish { timer.expectedFinish(at: now) }

    /// History by day and week in the Mac's current time zone and first weekday.
    var statistics: Statistics { history.statistics(at: now, calendar: .autoupdatingCurrent) }

    /// Nil while History is empty, so Clear History… can't be pressed.
    var clearHistoryConfirmation: Confirmation? { history.clearConfirmation }

    /// The one Start / Pause / Resume button.
    func startPauseResume() {
        send { $0.startPauseResume(at: $1) }
        // Asked on the first Start, after the timer is already running.
        if timer.status == .running, showNotifications {
            bannerNotifier.askPermission()
        }
    }

    /// Every window, the capsule included, follows Appearance straight away. System follows
    /// the Mac, switching as it does; Light and Dark ignore it.
    private func applyAppearance() {
        // NSApplication.shared rather than NSApp: the model is made while the app is starting up.
        NSApplication.shared.appearance = switch settings.appearance {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }

    func checkLoginItem() {
        loginItemStatus = LoginItem.status
    }

    /// The Open at login switch: registers or unregisters, then shows what macOS now says.
    func setOpensAtLogin(_ on: Bool) {
        LoginItem.turn(on: on)
        checkLoginItem()
    }

    /// A sound picked in Settings: saved, and played straight away so it can be heard.
    func chooseSound(_ name: String?, for sound: Sound) {
        settings.setSoundName(name, for: sound)
        soundPlayer.play(name)
    }

    /// Asks macOS whether Pomodot's notifications are turned off, for the warning in Settings.
    func checkWhetherNotificationsAreTurnedOff() {
        bannerNotifier.checkTurnedOffInSystemSettings { [weak self] turnedOff in
            self?.notificationsTurnedOffInSystemSettings = turnedOff
        }
    }

    func skip() {
        send { $0.skip(at: $1) }
    }

    func reset() {
        send { $0.reset(at: $1) }
    }

    func newCycle() {
        send { $0.newCycle(at: $1) }
    }

    /// Empties History. The timer stays where it is.
    func clearHistory() {
        history.clear()
        saveHistory()
    }

    private func sleep() {
        send { $0.sleep(at: $1) }
    }

    private func tick() {
        send(isTick: true) { $0.tick(at: $1) }
    }

    /// Quit Pomodot: counts a Phase that has just run out, without a sound or banner,
    /// as any press does, then saves where the timer is.
    func saveBeforeQuitting() {
        send { TimerOutcome(pomodoros: $0.tick(at: $1).pomodoros) }
    }

    /// Hands one event to Core with the current time, saves, then redraws.
    /// - Parameter isTick: a tick that only moved the time on saves at most every 30 s.
    private func send(isTick: Bool = false, _ event: (inout PomodoroTimer, Date) -> TimerOutcome) {
        let now = Date()
        let outcome = event(&timer, now)
        record(outcome.pomodoros)
        if !isTick || outcome != TimerOutcome() || now.timeIntervalSince(lastStateSave) >= Self.saveInterval {
            saveState(at: now)
        }
        update(now)
        if let ranOut = outcome.ranOut {
            announce(ranOut)
        }
    }

    /// A Phase ran out by itself (the last one, after a late tick): play its sound once
    /// and post its banner.
    private func announce(_ ranOut: PhaseRanOut) {
        soundPlayer.play(settings.soundName(for: ranOut.sound))
        if let banner = ranOut.banner(showNotifications: showNotifications) {
            bannerNotifier.post(banner)
        }
    }

    private func update(_ now: Date) {
        self.now = now
        if timer.status == .running {
            startTicking()
        } else {
            stopTicking()
        }
        scheduleClock()
    }

    /// While Running, the ticks keep `now` fresh and Expected finish stays put. Otherwise
    /// Expected finish moves on with the clock ("if I pressed Start now"), so wake exactly
    /// when the minute it shows next changes, rather than redrawing every second.
    private func scheduleClock() {
        clock?.invalidate()
        clock = nil
        guard timer.status != .running else { return }
        let finish = expectedFinish
        let fire = min(nextMinuteChange(of: finish.phaseEnds), nextMinuteChange(of: finish.cycleEnds))
        let clock = Timer(fire: fire, interval: 0, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.update(Date()) }
        }
        RunLoop.main.add(clock, forMode: .common)
        self.clock = clock
    }

    /// When `end`, which moves along with the clock, next shows a different minute.
    private func nextMinuteChange(of end: Date) -> Date {
        let nextMinute = ((end.timeIntervalSinceReferenceDate / 60).rounded(.down) + 1) * 60
        return now.addingTimeInterval(nextMinute - end.timeIntervalSinceReferenceDate)
    }

    private func startTicking() {
        guard ticker == nil else { return }
        activity = ProcessInfo.processInfo.beginActivity(
            options: .userInitiatedAllowingIdleSystemSleep,
            reason: "Counting down a Pomodot Phase"
        )
        let ticker = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        // Common modes: keep ticking while the menu is open.
        RunLoop.main.add(ticker, forMode: .common)
        self.ticker = ticker
    }

    private func stopTicking() {
        ticker?.invalidate()
        ticker = nil
        if let activity {
            ProcessInfo.processInfo.endActivity(activity)
            self.activity = nil
        }
    }

    /// Saves each new Pomodoro to History straight away, before anything else is saved.
    private func record(_ pomodoros: [Pomodoro]) {
        guard !pomodoros.isEmpty else { return }
        history.record(pomodoros)
        saveHistory()
    }

    /// Rewrites history.json whole.
    private func saveHistory() {
        historyFile.save(HistoryFile.encode(history))
    }

    /// Rewrites state.json whole: the timer as if paused at `now`, and the Floating Window.
    private func saveState(at now: Date = Date()) {
        let window = FloatingWindowState(
            visible: isFloatingWindowVisible, alwaysOnTop: isAlwaysOnTop, center: capsuleCenter,
            hideNoticeShown: hideNoticeShown
        )
        stateFile.save(StateFile.encode(SavedState(timer: timer.snapshot(at: now), floatingWindow: window)))
        lastStateSave = now
    }
}
