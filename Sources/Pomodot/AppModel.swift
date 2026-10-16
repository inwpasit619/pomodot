import AppKit
import Core
import Observation

/// The one app-wide model the menu bar and the Floating Window share.
/// Timer state lives here, never in a window's view, because the user can hide the window.
/// The rules live in Core: this only feeds it button presses, sleep and ticks, with the clock.
@MainActor
@Observable
final class AppModel {
    /// Shown on first launch. Not remembered across launches yet.
    var isFloatingWindowVisible = true
    /// On by default. Not remembered across launches yet.
    var isAlwaysOnTop = true
    /// On by default; Settings (M5) can turn it off. Off: no permission asked, no banners,
    /// but the sounds still play.
    var showNotifications = true

    private(set) var timer = PomodoroTimer()
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
    @ObservationIgnored private let soundPlayer = SoundPlayer()
    @ObservationIgnored private let bannerNotifier = BannerNotifier()

    init() {
        history = historyFile.load(HistoryFile.decode)
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
        // Clicking a banner brings the Floating Window back if it was hidden.
        bannerNotifier.onClick = { [weak self] in self?.isFloatingWindowVisible = true }
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
        send { $0.tick(at: $1) }
    }

    /// Hands one event to Core with the current time, then redraws.
    private func send(_ event: (inout PomodoroTimer, Date) -> TimerOutcome) {
        let now = Date()
        let outcome = event(&timer, now)
        record(outcome.pomodoros)
        update(now)
        if let ranOut = outcome.ranOut {
            announce(ranOut)
        }
    }

    /// A Phase ran out by itself (the last one, after a late tick): play its sound once
    /// and post its banner.
    private func announce(_ ranOut: PhaseRanOut) {
        soundPlayer.play(ranOut.sound)
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
}
