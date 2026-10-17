import Core
import Observation
import SwiftUI

/// Counts the numbers Core changed after they were typed (200 minutes kept to 120), so the
/// field redraws them instead of still showing what was typed. A class the window controller
/// owns, as `@State` needs a macro plugin the Command Line Tools don't ship.
@MainActor
@Observable
final class TypedNumberCorrections {
    var count = 0
}

/// One page of rounded boxes, as System Settings draws them. There is no Save button:
/// each change goes straight to the model, which saves it and hands it to the timer.
struct SettingsView: View {
    @Bindable var model: AppModel
    let corrections: TypedNumberCorrections

    var body: some View {
        let minutes = TimerSettings.minutesRange
        VStack(spacing: 0) {
            Form {
                Section {
                    Toggle("Open at login", isOn: Binding(
                        get: { model.loginItemStatus.isOn },
                        set: { model.setOpensAtLogin($0) }
                    ))
                    // A switch macOS refused to change goes back to what macOS says.
                    .id(model.loginItemRefusals)
                    if model.loginItemStatus.needsApproval {
                        SystemSettingsWarning(
                            "Pomodot needs your approval in System Settings to open at login.",
                            button: "Open Login Items…",
                            action: LoginItem.openSystemSettings
                        )
                    }
                    Toggle("Show in Dock", isOn: $model.settings.showInDock)
                } header: {
                    SectionTitle("General")
                }

                Section {
                    NumberRow("Focus", value: $model.settings.timer.focusMinutes, in: minutes, unit: "min", corrections: corrections)
                    NumberRow("Short Break", value: $model.settings.timer.shortBreakMinutes, in: minutes, unit: "min", corrections: corrections)
                    NumberRow("Long Break", value: $model.settings.timer.longBreakMinutes, in: minutes, unit: "min", corrections: corrections)
                    NumberRow(
                        "Pomodoros per Cycle",
                        value: $model.settings.timer.pomodorosPerCycle,
                        in: TimerSettings.pomodorosPerCycleRange,
                        unit: nil,
                        corrections: corrections
                    )
                } header: {
                    SectionTitle("Timer")
                }

                Section {
                    Toggle("Start breaks automatically", isOn: $model.settings.timer.autoStartBreaks)
                    Toggle(isOn: $model.settings.timer.autoStartFocus) {
                        Text("Start Focus automatically")
                        Text("(never after a Long Break)")
                    }
                } header: {
                    SectionTitle("Auto-start")
                }

                Section {
                    Toggle("Show notifications", isOn: $model.settings.showNotifications)
                    if model.warnsNotificationsAreOff {
                        SystemSettingsWarning(
                            "Notifications are turned off for Pomodot in System Settings.",
                            button: "Open System Settings…",
                            action: { NSWorkspace.shared.open(notificationSettingsURL) }
                        )
                    }
                    SoundPicker("End of Focus sound", sound: .focus, model: model)
                    SoundPicker("End of Break sound", sound: .break, model: model)
                } header: {
                    SectionTitle("Notifications & Sound")
                }

                Section {
                    Picker("Appearance", selection: $model.settings.appearance) {
                        ForEach(Appearance.allCases, id: \.self) { appearance in
                            Text(appearance.name).tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                } header: {
                    SectionTitle("Appearance")
                }
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            .toggleStyle(.switch)

            HStack {
                Spacer()
                Button("Restore Defaults") {
                    model.settings.restoreDefaults()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.horizontal, .bottom], 20)
        }
        .tint(PhaseColor.focus)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// A label, then a whole-number field with up and down arrows: "Focus  [ 25 ] min ⇅".
/// Core keeps the number within its range: typing 200 minutes gives 120.
private struct NumberRow: View {
    let title: String
    let value: Binding<Int>
    let range: ClosedRange<Int>
    let unit: String?
    let corrections: TypedNumberCorrections

    init(
        _ title: String, value: Binding<Int>, in range: ClosedRange<Int>, unit: String?,
        corrections: TypedNumberCorrections
    ) {
        self.title = title
        self.value = value
        self.range = range
        self.unit = unit
        self.corrections = corrections
    }

    /// What is typed goes to Core; when Core keeps a different number, the field is redrawn with it.
    private var typed: Binding<Int> {
        Binding(
            get: { value.wrappedValue },
            set: { number in
                value.wrappedValue = number
                if value.wrappedValue != number {
                    corrections.count += 1
                }
            }
        )
    }

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 6) {
                TextField(title, value: typed, format: .number)
                    .id(corrections.count)
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
                    .monospacedDigit()
                    .frame(width: 48)
                Text(unit ?? "min")
                    .foregroundStyle(.secondary)
                    // An invisible "min" keeps every field lined up, with or without a unit.
                    .opacity(unit == nil ? 0 : 1)
                    .accessibilityHidden(unit == nil)
                Stepper(title, value: value, in: range)
                    .labelsHidden()
            }
        }
    }
}

/// Pomodot's own page under Notifications in System Settings.
private let notificationSettingsURL = URL(
    string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(Bundle.main.bundleIdentifier ?? "")"
)!

/// An orange line under a switch while System Settings stands in its way (notifications turned
/// off, Open at login waiting for approval), with a button that goes there.
private struct SystemSettingsWarning: View {
    let message: String
    let button: String
    let action: () -> Void

    init(_ message: String, button: String, action: @escaping () -> Void) {
        self.message = message
        self.button = button
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Button(button, action: action)
                // Its own grey button: the tomato red is for the window's main button and switches.
                .tint(nil)
        }
    }
}

/// A sound dropdown: None, then every system sound. Picking one saves it and plays it straight
/// away; there is no separate play button.
private struct SoundPicker: View {
    let title: String
    let sound: Sound
    let model: AppModel

    init(_ title: String, sound: Sound, model: AppModel) {
        self.title = title
        self.sound = sound
        self.model = model
    }

    var body: some View {
        // Through the model, not straight into Settings: only a pick plays the sound,
        // never Restore Defaults.
        let choice = Binding(
            get: { model.settings.soundName(for: sound) },
            set: { model.chooseSound($0, for: sound) }
        )
        Picker(title, selection: choice) {
            ForEach(model.soundChoices, id: \.self) { name in
                // Every tag is a String?, as the selection is: None is nil.
                Text(name ?? "None").tag(name)
            }
        }
    }
}
