//
//  SteriumEventsCalendarView.swift
//  Sterium
//
//  Month grid with per-day event markers and a selected-day list.
//

import SwiftUI

struct SteriumEventsCalendarView: View {
    @Binding var focusedDate: Date
    let events: [SteriumEvent]
    let onSelect: (UUID) -> Void

    @State private var selectedDay = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 7)
    private static let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: focusedDate)
            ?? DateInterval(start: focusedDate, duration: 31 * 86_400)
    }

    private var monthOccurrences: [SteriumEventOccurrence] {
        // Expand a little past the visible month so leading/trailing days
        // from adjacent months still show markers.
        let padded = DateInterval(
            start: calendar.date(byAdding: .day, value: -7, to: monthInterval.start) ?? monthInterval.start,
            end: calendar.date(byAdding: .day, value: 7, to: monthInterval.end) ?? monthInterval.end
        )
        return events.flatMap { $0.occurrences(in: padded, calendar: calendar) }
    }

    var body: some View {
        VStack(spacing: 14) {
            monthHeader

            LazyVGrid(columns: columns, spacing: 7) {
                ForEach(Self.weekdayLabels.indices, id: \.self) { index in
                    Text(Self.weekdayLabels[index])
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
                ForEach(monthDays, id: \.self) { day in
                    dayCell(day)
                }
            }

            selectedDaySection
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
    }

    private var monthHeader: some View {
        HStack {
            Button { moveMonth(-1) } label: {
                Image("chevleft").renderingMode(.template).resizable().scaledToFit()
                    .frame(width: 18, height: 18).foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
            Spacer()
            Text(focusedDate.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Spacer()
            Button { moveMonth(1) } label: {
                Image("chevright").renderingMode(.template).resizable().scaledToFit()
                    .frame(width: 18, height: 18).foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }

    private var monthDays: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: focusedDate) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leading = max(0, firstWeekday - 1)
        var days: [Date] = []
        for offset in stride(from: leading, to: 0, by: -1) {
            if let d = calendar.date(byAdding: .day, value: -offset, to: monthInterval.start) { days.append(d) }
        }
        for n in range {
            if let d = calendar.date(byAdding: .day, value: n - 1, to: monthInterval.start) { days.append(d) }
        }
        while days.count % 7 != 0 {
            if let last = days.last, let next = calendar.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            } else { break }
        }
        return days
    }

    private func dayCell(_ day: Date) -> some View {
        let isCurrentMonth = calendar.isDate(day, equalTo: focusedDate, toGranularity: .month)
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDay)
        let dayRows = rows(on: day)

        return Button {
            selectedDay = day
            focusedDate = day
        } label: {
            GlassCard(cornerRadius: 14, padding: 7) {
                VStack(spacing: 5) {
                    Text("\(calendar.component(.day, from: day))")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(isCurrentMonth ? LColors.textPrimary : LColors.textSecondary.opacity(0.45))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 3) {
                        ForEach(dayRows.prefix(3)) { _ in
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(LGradients.header)
                                .frame(height: 5)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 19, alignment: .top)
                }
                .frame(height: 50)
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(LGradients.header, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedDay.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            let dayRows = rows(on: selectedDay)
            if dayRows.isEmpty {
                SteriumEventsEmptyState(title: "No Events", subtitle: "Nothing is scheduled for this day.")
            } else {
                ForEach(dayRows) { row in
                    SteriumEventRow(occurrence: row) { onSelect(row.eventID) }
                }
            }
        }
    }

    private func rows(on day: Date) -> [SteriumEventOccurrence] {
        monthOccurrences
            .filter { $0.occurs(on: day, calendar: calendar) }
            .sorted { $0.start < $1.start }
    }

    private func moveMonth(_ value: Int) {
        focusedDate = calendar.date(byAdding: .month, value: value, to: focusedDate) ?? focusedDate
        selectedDay = focusedDate
    }
}
