//
//  SteriumEventsAgendaView.swift
//  Sterium
//
//  Upcoming events as a chronological list grouped by day.
//

import SwiftUI

struct SteriumEventsAgendaView: View {
    let events: [SteriumEvent]
    let onSelect: (UUID) -> Void

    private let calendar = Calendar.current

    private var interval: DateInterval {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 60, to: start) ?? start.addingTimeInterval(60 * 86_400)
        return DateInterval(start: start, end: end)
    }

    private var groups: [DayGroup] {
        let todayStart = calendar.startOfDay(for: Date())
        let occurrences = events
            .flatMap { $0.occurrences(in: interval, calendar: calendar) }
            .filter { $0.end >= todayStart }
            .sorted { $0.start < $1.start }

        let grouped = Dictionary(grouping: occurrences) { calendar.startOfDay(for: $0.start) }
        return grouped.keys.sorted().map { day in
            DayGroup(day: day, rows: (grouped[day] ?? []).sorted { $0.start < $1.start })
        }
    }

    private struct DayGroup: Identifiable {
        let day: Date
        let rows: [SteriumEventOccurrence]
        var id: Date { day }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if groups.isEmpty {
                SteriumEventsEmptyState(
                    title: "No Upcoming Events",
                    subtitle: "Tap the pencil above to create your first event."
                )
            } else {
                ForEach(groups) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        dayHeader(group.day)
                        ForEach(group.rows) { row in
                            SteriumEventRow(occurrence: row) { onSelect(row.eventID) }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
    }

    private func dayHeader(_ day: Date) -> some View {
        HStack(spacing: 8) {
            Text(dayLabel(day))
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LGradients.header)
            Spacer()
            Text(day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
        }
    }

    private func dayLabel(_ day: Date) -> String {
        if calendar.isDateInToday(day) { return "TODAY" }
        if calendar.isDateInTomorrow(day) { return "TOMORROW" }
        return day.formatted(.dateTime.weekday(.abbreviated)).uppercased()
    }
}
