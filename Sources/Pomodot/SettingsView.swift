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
