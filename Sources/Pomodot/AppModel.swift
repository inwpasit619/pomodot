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

    private(set) var timer = PomodoroTimer()
    /// The clock time the views draw from. Each tick moves it on.
    private(set) var now = Date()

    /// Sends `tick` about once a second, only while Running.
    @ObservationIgnored private var ticker: Timer?
    /// Keeps macOS from delaying the ticks while Running; idle sleep still allowed.
    @ObservationIgnored private var activity: NSObjectProtocol?

    init() {
        // Only real sleep (lid closed, Sleep chosen). Locking the screen, the display
        // going off and the screensaver send nothing: the timer keeps running.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.sleep() }
        }
    }

    var remainingSeconds: Int { timer.remainingSeconds(at: now) }

    /// The one Start / Pause / Resume button.
    func startPauseResume() {
        send { $0.startPauseResume(at: $1) }
    }

    private func sleep() {
        send { $0.sleep(at: $1) }
    }

    private func tick() {
        send { $0.tick(at: $1) }
    }

    /// Hands one event to Core with the current time, then redraws.
    private func send(_ event: (inout PomodoroTimer, Date) -> [Pomodoro]) {
        let now = Date()
        record(event(&timer, now))
        update(now)
    }

    private func update(_ now: Date) {
        self.now = now
        if timer.status == .running {
            startTicking()
        } else {
            stopTicking()
        }
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

    /// History arrives in M4; until then each Pomodoro only goes to the system log.
    private func record(_ pomodoros: [Pomodoro]) {
        for pomodoro in pomodoros {
            NSLog("Pomodot: Pomodoro ended %@ (%d s)",
                  pomodoro.end.ISO8601Format(), pomodoro.durationSeconds)
        }
    }
}
