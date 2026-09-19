//
//  SteriumEvent.swift
//  Sterium
//
//  Basic calendar events with recurrence. Shared with the SteriumShare
//  extension only so the unified App Group store's schema compiles in both
//  targets — the extension never creates events.
//

import Foundation
import SwiftData

// MARK: - Enums

enum SteriumEventFrequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

enum SteriumEventWeekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

enum SteriumEventRecurrenceEndType: String, Codable, CaseIterable, Identifiable {
    case never
    case onDate
    case afterOccurrences

    var id: String { rawValue }

    var label: String {
        switch self {
        case .never: return "Never"
        case .onDate: return "On Date"
        case .afterOccurrences: return "After Count"
        }
    }
}

enum SteriumEventReminder: Int, CaseIterable, Identifiable {
    case atTime = 0
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case oneDay = 1440

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .atTime: return "At time of event"
        case .fiveMinutes: return "5 minutes before"
        case .tenMinutes: return "10 minutes before"
        case .fifteenMinutes: return "15 minutes before"
        case .thirtyMinutes: return "30 minutes before"
        case .oneHour: return "1 hour before"
        case .oneDay: return "1 day before"
        }
    }
}

// MARK: - Model

@Model
final class SteriumEvent {
    var id: UUID = UUID()
    var title: String = ""
    var eventDescription: String = ""
    var iconName: String = "starcal"
    var startDate: Date = Date()
    var endDate: Date?
    var isAllDay: Bool = false
    var meetingLink: String = ""

    /// Minutes before the event to fire a reminder. nil = no reminder.
    var reminderOffsetMinutes: Int?

    // Inline recurrence. nil frequency = one-time event.
    var recurrenceFrequencyRaw: String?
    var recurrenceInterval: Int = 1
    var recurrenceWeekdaysStorage: String = "[]"
    var recurrenceEndTypeRaw: String = SteriumEventRecurrenceEndType.never.rawValue
    var recurrenceEndDate: Date?
    var recurrenceOccurrenceCount: Int?

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        title: String = "",
        eventDescription: String = "",
        iconName: String = "starcal",
        startDate: Date = Date(),
        endDate: Date? = nil,
        isAllDay: Bool = false,
        meetingLink: String = "",
        reminderOffsetMinutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.iconName = iconName
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.meetingLink = meetingLink
        self.reminderOffsetMinutes = reminderOffsetMinutes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Derived accessors

extension SteriumEvent {
    var frequency: SteriumEventFrequency? {
        get {
            guard let recurrenceFrequencyRaw else { return nil }
            return SteriumEventFrequency(rawValue: recurrenceFrequencyRaw)
        }
        set { recurrenceFrequencyRaw = newValue?.rawValue }
    }

    var isRecurring: Bool { frequency != nil }

    var recurrenceWeekdays: [SteriumEventWeekday] {
        get {
            guard let data = recurrenceWeekdaysStorage.data(using: .utf8),
                  let values = try? JSONDecoder().decode([Int].self, from: data) else { return [] }
            return values.compactMap { SteriumEventWeekday(rawValue: $0) }
        }
        set {
            let values = newValue.map(\.rawValue).sorted()
            if let data = try? JSONEncoder().encode(values),
               let json = String(data: data, encoding: .utf8) {
                recurrenceWeekdaysStorage = json
            }
        }
    }

    var recurrenceEndType: SteriumEventRecurrenceEndType {
        get { SteriumEventRecurrenceEndType(rawValue: recurrenceEndTypeRaw) ?? .never }
        set { recurrenceEndTypeRaw = newValue.rawValue }
    }

    var reminder: SteriumEventReminder? {
        get {
            guard let reminderOffsetMinutes else { return nil }
            return SteriumEventReminder(rawValue: reminderOffsetMinutes)
        }
        set { reminderOffsetMinutes = newValue?.rawValue }
    }

    var displayIcon: String {
        iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "starcal" : iconName
    }

    /// Human-readable recurrence summary, e.g. "Every 2 weeks".
    var recurrenceSummary: String? {
        guard let frequency else { return nil }
        let n = max(1, recurrenceInterval)
        let unit: String
        switch frequency {
        case .daily: unit = n == 1 ? "day" : "days"
        case .weekly: unit = n == 1 ? "week" : "weeks"
        case .monthly: unit = n == 1 ? "month" : "months"
        case .yearly: unit = n == 1 ? "year" : "years"
        }
        return n == 1 ? "Every \(unit)" : "Every \(n) \(unit)"
    }
}

// MARK: - Occurrence

struct SteriumEventOccurrence: Identifiable, Hashable {
    let eventID: UUID
    let title: String
    let iconName: String
    let start: Date
    let end: Date
    let isAllDay: Bool

    var id: String { "\(eventID.uuidString)-\(Int(start.timeIntervalSince1970))" }

    var timeSubtitle: String {
        if isAllDay { return "All day" }
        return "\(start.formatted(date: .omitted, time: .shortened)) – \(end.formatted(date: .omitted, time: .shortened))"
    }

    func occurs(on day: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(start, inSameDayAs: day)
            || (start < calendar.startOfDay(for: day)
                && end > calendar.startOfDay(for: day))
    }
}

// MARK: - Occurrence expansion

extension SteriumEvent {
    private var durationSeconds: TimeInterval {
        if let endDate, endDate > startDate {
            return endDate.timeIntervalSince(startDate)
        }
        return 3600
    }

    func occurrenceStart(on day: Date, calendar: Calendar = .current) -> Date {
        if isAllDay { return calendar.startOfDay(for: day) }
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        let time = calendar.dateComponents([.hour, .minute], from: startDate)
        components.hour = time.hour
        components.minute = time.minute
        return calendar.date(from: components) ?? startDate
    }

    func occurrenceEnd(for start: Date, calendar: Calendar = .current) -> Date {
        if isAllDay {
            let sourceEnd = endDate ?? startDate
            let daySpan = max(0, calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: startDate),
                to: calendar.startOfDay(for: sourceEnd)
            ).day ?? 0)
            return calendar.date(byAdding: .day, value: daySpan + 1, to: calendar.startOfDay(for: start)) ?? start
        }
        return start.addingTimeInterval(durationSeconds)
    }

    private func makeOccurrence(start: Date, end: Date) -> SteriumEventOccurrence {
        SteriumEventOccurrence(
            eventID: id,
            title: title,
            iconName: displayIcon,
            start: start,
            end: end,
            isAllDay: isAllDay
        )
    }

    func occurrences(in interval: DateInterval, calendar: Calendar = .current) -> [SteriumEventOccurrence] {
        guard frequency != nil else {
            let start = occurrenceStart(on: startDate, calendar: calendar)
            let end = occurrenceEnd(for: start, calendar: calendar)
            guard intersects(start: start, end: end, interval: interval) else { return [] }
            return [makeOccurrence(start: start, end: end)]
        }
        return recurringOccurrences(in: interval, calendar: calendar)
    }

    private func recurringOccurrences(in interval: DateInterval, calendar: Calendar) -> [SteriumEventOccurrence] {
        var results: [SteriumEventOccurrence] = []
        var candidate = calendar.startOfDay(for: startDate)
        let searchEnd = interval.end
        var generated = 0
        var guardCounter = 0
        let guardLimit = 4000  // safety cap on the day walk

        while candidate <= searchEnd {
            guardCounter += 1
            if guardCounter > guardLimit { break }

            if matches(candidate, calendar: calendar) {
                generated += 1
                if shouldStop(candidate: candidate, generated: generated, calendar: calendar) { break }

                let start = occurrenceStart(on: candidate, calendar: calendar)
                let end = occurrenceEnd(for: start, calendar: calendar)
                if intersects(start: start, end: end, interval: interval) {
                    results.append(makeOccurrence(start: start, end: end))
                }
            }

            guard let next = calendar.date(byAdding: .day, value: 1, to: candidate) else { break }
            candidate = next
        }

        return results
    }

    private func intersects(start: Date, end: Date, interval: DateInterval) -> Bool {
        let realEnd = max(end, start.addingTimeInterval(60))
        return start < interval.end && realEnd > interval.start
    }

    private func shouldStop(candidate: Date, generated: Int, calendar: Calendar) -> Bool {
        switch recurrenceEndType {
        case .never:
            return false
        case .onDate:
            guard let recurrenceEndDate else { return false }
            return calendar.startOfDay(for: candidate) > calendar.startOfDay(for: recurrenceEndDate)
        case .afterOccurrences:
            guard let recurrenceOccurrenceCount else { return false }
            return generated > max(0, recurrenceOccurrenceCount)
        }
    }

    private func matches(_ day: Date, calendar: Calendar) -> Bool {
        let startDay = calendar.startOfDay(for: startDate)
        guard day >= startDay, let frequency else { return false }
        let step = max(1, recurrenceInterval)

        switch frequency {
        case .daily:
            let days = calendar.dateComponents([.day], from: startDay, to: day).day ?? 0
            return days % step == 0
        case .weekly:
            let weeks = calendar.dateComponents([.weekOfYear], from: startDay, to: day).weekOfYear ?? 0
            guard weeks % step == 0 else { return false }
            let weekday = calendar.component(.weekday, from: day)
            let selected = recurrenceWeekdays.map(\.rawValue)
            return selected.isEmpty
                ? weekday == calendar.component(.weekday, from: startDay)
                : selected.contains(weekday)
        case .monthly:
            let months = calendar.dateComponents([.month], from: startDay, to: day).month ?? 0
            guard months % step == 0 else { return false }
            return calendar.component(.day, from: day) == calendar.component(.day, from: startDay)
        case .yearly:
            let years = calendar.dateComponents([.year], from: startDay, to: day).year ?? 0
            guard years % step == 0 else { return false }
            return calendar.component(.month, from: day) == calendar.component(.month, from: startDay)
                && calendar.component(.day, from: day) == calendar.component(.day, from: startDay)
        }
    }
}
