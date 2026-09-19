//
//  SteriumEventNotificationManager.swift
//  Sterium
//
//  Schedules local reminder notifications for events, expanding recurring
//  occurrences across a one-year horizon. App-only.
//

import Foundation
import SwiftData
import UserNotifications

@MainActor
final class SteriumEventNotificationManager {
    static let shared = SteriumEventNotificationManager()

    private let prefix = "sterium.event."
    private let maxRequestsPerEvent = 60
    private let horizon: TimeInterval = 366 * 24 * 60 * 60

    private init() {}

    /// Requests notification authorization if not already determined.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    /// Cancels then (re)schedules reminders for a single event.
    func scheduleNotifications(for event: SteriumEvent) {
        let eventID = event.id
        guard let offset = event.reminderOffsetMinutes else {
            Task { await cancelNotifications(eventID: eventID) }
            return
        }

        let title = event.title.isEmpty ? "Event" : event.title
        let body = reminderBody(for: event)
        let now = Date()
        let interval = DateInterval(start: now, end: now.addingTimeInterval(horizon))
        let occurrences = event.occurrences(in: interval).sorted { $0.start < $1.start }

        Task {
            let granted = await requestAuthorization()
            await cancelNotifications(eventID: eventID)
            guard granted else { return }

            var count = 0
            for occurrence in occurrences {
                guard count < maxRequestsPerEvent else { break }
                let fireDate = occurrence.start.addingTimeInterval(TimeInterval(-offset * 60))
                guard fireDate > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let identifier = "\(prefix)\(eventID.uuidString).\(Int(occurrence.start.timeIntervalSince1970))"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                try? await UNUserNotificationCenter.current().add(request)
                count += 1
            }
        }
    }

    func cancelNotifications(for event: SteriumEvent) {
        let eventID = event.id
        Task { await cancelNotifications(eventID: eventID) }
    }

    private func reminderBody(for event: SteriumEvent) -> String {
        let description = event.eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if description.isEmpty == false { return description }
        if event.isAllDay { return "All-day event today." }
        return "Starting \(event.startDate.formatted(date: .omitted, time: .shortened))."
    }

    private func cancelNotifications(eventID: UUID) async {
        let eventPrefix = "\(prefix)\(eventID.uuidString)."
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(eventPrefix) }
        guard ids.isEmpty == false else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
}
