import Core
import SwiftUI

// How each Phase and status looks: colours, SF Symbols and words.

enum PhaseColor {
    /// Tomato red, #F0524F.
    static let focus = Color(red: 0xF0 / 255, green: 0x52 / 255, blue: 0x4F / 255)
    /// Green, #2FBF5B.
    static let shortBreak = Color(red: 0x2F / 255, green: 0xBF / 255, blue: 0x5B / 255)
    /// Blue, #0A84FF.
    static let longBreak = Color(red: 0x0A / 255, green: 0x84 / 255, blue: 0xFF / 255)

    static func of(_ phase: Phase) -> Color {
        switch phase {
        case .focus: focus
        case .shortBreak: shortBreak
        case .longBreak: longBreak
        }
    }
}

extension PhaseStatus {
    /// The word next to the time; Running shows none.
    var capsuleLabel: String? {
        switch self {
        case .ready: "READY"
        case .running: nil
        case .paused: "PAUSED"
        }
    }

    /// The menu's one Start / Pause / Resume line.
    var startPauseResumeTitle: String {
        switch self {
        case .ready: "Start"
        case .running: "Pause"
        case .paused: "Resume"
        }
    }
}

extension PomodoroTimer {
    /// Progress in the Cycle as the card and the menu write it: "2/4".
    var progressText: String {
        "\(displayNumber)/\(pomodorosPerCycle)"
    }
}

extension Phase {
    /// The menu bar icon while this Phase is Running or Ready.
    var menuBarSymbol: String {
        self == .focus ? "timer" : "cup.and.saucer.fill"
    }
}
