//
//  GetUpcomingSabbatIntent.swift
//  Sterium
//
//  Thin App Intent bridging the existing Upcoming Sabbat dashboard data
//  (DailySpiritualCalculator.nextSabbat) to Apple Shortcuts as structured output.
//  Uses TransientAppEntity so each @Property becomes a separately
//  selectable magic variable in Shortcuts.
//

import AppIntents
import Foundation

// MARK: - Transient entity

struct UpcomingSabbatEntity: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Upcoming Sabbat")
    }

    @Property(title: "Sabbat Name")
    var sabbatName: String

    @Property(title: "Date")
    var date: Date

    @Property(title: "Days Remaining")
    var daysRemaining: Int

    @Property(title: "Live Countdown")
    var liveCountdown: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(sabbatName)",
            subtitle: "\(daysRemaining) days - \(liveCountdown)"
        )
    }

    init() {
        self.sabbatName = ""
        self.date = Date()
        self.daysRemaining = 0
        self.liveCountdown = ""
    }

    init(from sabbat: SabbatInfo, now: Date) {
        self.sabbatName = sabbat.name
        self.date = sabbat.date
        self.daysRemaining = sabbat.countdown(from: now)
        self.liveCountdown = Self.formatCountdown(from: now, to: sabbat.date)
    }

    // Mirrors HomeView.liveSabbatCountdown so the dashboard and Shortcuts
    // always show the same live value.
    static func formatCountdown(from now: Date, to target: Date) -> String {
        let remaining = max(target.timeIntervalSince(now), 0)
        let totalSeconds = Int(remaining)
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        return "\(days)D \(hours)H \(minutes)M \(seconds)S"
    }
}

// MARK: - Intent

struct GetUpcomingSabbatIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Upcoming Sabbat"

    static var description = IntentDescription(
        "Returns the next Sabbat name, date, days remaining, and a live countdown."
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<UpcomingSabbatEntity> {
        let now = Date()
        let sabbat = DailySpiritualCalculator.nextSabbat(from: now)
        return .result(value: UpcomingSabbatEntity(from: sabbat, now: now))
    }
}
