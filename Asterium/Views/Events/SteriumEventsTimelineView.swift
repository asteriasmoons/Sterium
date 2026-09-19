//
//  SteriumEventsTimelineView.swift
//  Sterium
//
//  A week strip plus a vertical timeline of the selected day's events.
//

import SwiftUI

struct SteriumEventsTimelineView: View {
    @Binding var focusedDate: Date
    let events: [SteriumEvent]
    let onSelect: (UUID) -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 16) {
            weekCard
            selectedDayHeader
            timelineOrEmpty
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
    }

    // MARK: - Week strip

    private var weekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: focusedDate)?.start
            ?? calendar.startOfDay(for: focusedDate)
    }

    private var weekDays: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var weekInterval: DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: focusedDate)
            ?? DateInterval(start: weekStart, duration: 7 * 86_400)
    }

    private var weekRangeText: String {
        guard let end = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return focusedDate.formatted(date: .abbreviated, time: .omitted)
        }
        let s = weekStart.formatted(.dateTime.month(.abbreviated).day())
        let e = end.formatted(.dateTime.month(.abbreviated).day())
        return "\(s) – \(e)"
    }

    private var weekCard: some View {
        GlassCard(cornerRadius: 24, padding: 12) {
            VStack(spacing: 10) {
                HStack {
                    Button { moveWeek(-1) } label: { chev("chevleft") }
                        .buttonStyle(.plain)
                    Spacer()
                    Text(weekRangeText)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary.opacity(0.85))
                    Spacer()
                    Button { moveWeek(1) } label: { chev("chevright") }
                        .buttonStyle(.plain)
                }

                HStack(spacing: 7) {
                    ForEach(weekDays, id: \.self) { day in
                        dayTile(day)
                    }
                }
            }
        }
    }

    private func chev(_ asset: String) -> some View {
        Image(asset)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 22, height: 22)
            .foregroundStyle(LGradients.header)
            .frame(width: 32, height: 32)
    }

    private func dayTile(_ day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: focusedDate)
        let isToday = calendar.isDateInToday(day)
        let hasEvents = dayHasEvents(day)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { focusedDate = day }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? LColors.glassSurface2 : LColors.glassSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(isSelected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassBorder),
                                          lineWidth: isSelected ? 1.5 : 1)
                    }

                VStack(spacing: 5) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(isSelected ? LColors.textPrimary : LColors.textSecondary)
                    Text(day.formatted(.dateTime.day()))
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(isSelected ? LColors.textPrimary : LColors.textPrimary.opacity(0.8))
                    Circle()
                        .fill(hasEvents ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(Color.clear))
                        .frame(width: 4, height: 4)
                        .opacity(isToday && !hasEvents ? 0.5 : 1)
                        .overlay {
                            if isToday && !hasEvents {
                                Circle().fill(LColors.textSecondary).frame(width: 4, height: 4)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
        }
        .buttonStyle(.plain)
    }

    private func moveWeek(_ value: Int) {
        guard let newDay = calendar.date(byAdding: .weekOfYear, value: value, to: focusedDate) else { return }
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { focusedDate = newDay }
    }

    // MARK: - Occurrences

    private var weekOccurrences: [SteriumEventOccurrence] {
        events.flatMap { $0.occurrences(in: weekInterval, calendar: calendar) }
    }

    private func dayHasEvents(_ day: Date) -> Bool {
        weekOccurrences.contains { $0.occurs(on: day, calendar: calendar) }
    }

    private var dayRows: [SteriumEventOccurrence] {
        weekOccurrences
            .filter { $0.occurs(on: focusedDate, calendar: calendar) }
            .sorted { $0.start < $1.start }
    }

    // MARK: - Selected day header

    private var selectedDayHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(focusedDate.formatted(date: .complete, time: .omitted))
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("\(dayRows.count) item\(dayRows.count == 1 ? "" : "s") scheduled")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) { focusedDate = Date() }
            } label: {
                Text("Today")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(.horizontal, 12)
                    .frame(height: 28)
                    .background {
                        Capsule().fill(LColors.glassSurface)
                            .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                    }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Timeline

    private struct TimeGroup: Identifiable {
        let id: String
        let label: String
        let sortKey: Date
        let rows: [SteriumEventOccurrence]
    }

    private var groupedRows: [TimeGroup] {
        let rows = dayRows
        let allDay = rows.filter { $0.isAllDay }
        let timed = rows.filter { !$0.isAllDay }
        var groups: [TimeGroup] = []

        if allDay.isEmpty == false {
            groups.append(TimeGroup(id: "all-day", label: "All Day", sortKey: .distantPast,
                                    rows: allDay.sorted { $0.title < $1.title }))
        }

        let buckets = Dictionary(grouping: timed) { $0.start.formatted(date: .omitted, time: .shortened) }
        for (label, bucketRows) in buckets {
            let sorted = bucketRows.sorted { $0.start < $1.start }
            groups.append(TimeGroup(id: label, label: label, sortKey: sorted.first?.start ?? .distantFuture, rows: sorted))
        }
        return groups.sorted { $0.sortKey < $1.sortKey }
    }

    @ViewBuilder
    private var timelineOrEmpty: some View {
        if dayRows.isEmpty {
            SteriumEventsEmptyState(title: "No Events", subtitle: "Nothing is scheduled for this day.")
        } else {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(LColors.glassBorderStrong)
                    .frame(width: 2)
                    .padding(.leading, 18)
                    .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(groupedRows) { group in
                        marker(group.label)
                        ForEach(group.rows) { row in
                            HStack(spacing: 0) {
                                Color.clear.frame(width: 48)
                                SteriumEventRow(occurrence: row) { onSelect(row.eventID) }
                            }
                        }
                    }
                }
            }
        }
    }

    private func marker(_ title: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(LGradients.header).frame(width: 14, height: 14)
                Circle().strokeBorder(LColors.glassBorder, lineWidth: 1).frame(width: 14, height: 14)
            }
            .frame(width: 38)
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary.opacity(0.75))
                .tracking(0.4)
            Spacer()
        }
    }
}
