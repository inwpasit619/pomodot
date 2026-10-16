import Charts
import Core
import Observation
import SwiftUI

/// Which bar of the Last 7 Days chart the pointer is on. A class the window controller owns,
/// as `@State` needs a macro plugin the Command Line Tools don't ship.
@MainActor
@Observable
final class ChartHover {
    /// The bar's label, e.g. "Thu" or "Today".
    var label: String?
}

/// Today / This Week / All Time cards, the Last 7 Days chart and Clear History….
/// Draws from the model, so it updates by itself on a new Pomodoro and at midnight.
struct StatisticsView: View {
    let model: AppModel
    let hover: ChartHover
    let clearHistory: () -> Void

    var body: some View {
        let statistics = model.statistics
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                TotalCard(title: "Today", total: statistics.today)
                TotalCard(title: "This Week", total: statistics.thisWeek)
                TotalCard(title: "All Time", total: statistics.allTime)
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionTitle("Last 7 Days")
                LastSevenDaysChart(days: statistics.lastSevenDays, hover: hover)
                    .padding(16)
                    .background(BoxBackground())
            }

            HStack {
                Spacer()
                Button("Clear History…", action: clearHistory)
                    .disabled(model.clearHistoryConfirmation == nil)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}

/// One of the three cards: how many Pomodoros, and the Focus time they add up to.
private struct TotalCard: View {
    let title: String
    let total: FocusTotal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle(title)
            Text("🍅 \(total.pomodoros)")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .monospacedDigit()
            Text(TimeText.hoursMinutes(total.focusSeconds))
                .font(.system(.body, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(BoxBackground())
    }
}

/// A bar per day, oldest first, ending with Today. Today's bar is full tomato red,
/// the others lighter; a day with no Pomodoro keeps its slot with no bar.
private struct LastSevenDaysChart: View {
    let days: [DayTotal]
    let hover: ChartHover

    var body: some View {
        let most = days.map(\.total.pomodoros).max() ?? 0
        Chart(days, id: \.day) { day in
            let label = label(of: day)
            BarMark(
                x: .value("Day", label),
                y: .value("Pomodoros", day.total.pomodoros)
            )
            .foregroundStyle(day.isToday ? PhaseColor.focus : PhaseColor.focus.opacity(0.4))
            .cornerRadius(4)
            .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) {
                // Only a bar shows its numbers; a day with no Pomodoro has none.
                if hover.label == label, day.total.pomodoros > 0 {
                    Text("\(day.total.pomodoros) 🍅 · \(TimeText.hoursMinutes(day.total.focusSeconds))")
                        .font(.system(.caption, design: .rounded))
                        .monospacedDigit()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        // Headroom above the tallest bar for the hover label; whole Pomodoros on the axis.
        .chartYScale(domain: 0...max(4, most + most / 3 + 1))
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: Double(max(1, (most + 3) / 4)))) {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks { AxisValueLabel() }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            guard let plot = proxy.plotFrame else { return }
                            hover.label = proxy.value(atX: location.x - geometry[plot].origin.x, as: String.self)
                        case .ended:
                            hover.label = nil
                        }
                    }
            }
        }
        .frame(height: 180)
    }

    /// "Thu", "Fri", … and "Today" for the last day. The UI is English only.
    private func label(of day: DayTotal) -> String {
        guard !day.isToday else { return "Today" }
        return day.day.formatted(Date.FormatStyle(locale: Locale(identifier: "en_US")).weekday(.abbreviated))
    }
}

/// A section title in small grey type, as System Settings does it. Settings uses it too.
struct SectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            // A Form's section header is bold by default.
            .fontWeight(.regular)
            .foregroundStyle(.secondary)
    }
}

/// A rounded box like System Settings' grouped sections, in Light and Dark.
private struct BoxBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color(nsColor: .separatorColor))
            )
    }
}
