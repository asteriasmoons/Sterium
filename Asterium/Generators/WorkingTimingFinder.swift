//
//  WorkingTimingFinder.swift
//  Sterium
//
//  Deterministic, entirely-local timing engine for the Working Timing Finder.
//  The backend AI never chooses a date/time — it only returns a symbolic
//  profile. This engine walks upcoming planetary-hour windows (reusing the
//  app's existing calculators), scores each against the profile with a
//  centralized, adjustable weight table, and ranks them. Every awarded or
//  removed point is recorded as a reason so the detail UI can explain the pick.
//

import Foundation
import CoreLocation

// MARK: - Result models

struct WorkingTimingReason: Identifiable, Equatable, Sendable, Codable {
    var id = UUID()
    let text: String
    let points: Double
    var isPositive: Bool { points >= 0 }
}

struct WorkingTimingConditions: Equatable, Sendable, Codable {
    let start: Date
    let end: Date
    let planetaryDay: Planet
    let planetaryHour: Planet?
    let moonPhase: String
    let moonSign: String
    let numerology: Int
    let transits: [AstrologyTransit]
}

struct WorkingTimingWindow: Identifiable, Equatable, Sendable, Codable {
    var id = UUID()
    let conditions: WorkingTimingConditions
    let score: Double
    let reasons: [WorkingTimingReason]
    var rank: Int

    /// Positive-only reasons, strongest first.
    var supportingReasons: [WorkingTimingReason] { reasons.filter(\.isPositive).sorted { $0.points > $1.points } }
    /// Negative reasons.
    var challengingReasons: [WorkingTimingReason] { reasons.filter { !$0.isPositive } }

    var strengthLabel: String {
        switch score {
        case 16...: return "Very Strong"
        case 11..<16: return "Strong"
        case 6..<11: return "Good"
        case 1..<6: return "Fair"
        default: return "Weak"
        }
    }
}

struct WorkingTimingResult: Equatable, Sendable, Codable {
    let profile: WorkingTimingProfile
    let best: WorkingTimingWindow
    let alternatives: [WorkingTimingWindow]

    /// Raw text the user entered for this working (kept for the saved snapshot).
    /// Defaults to empty so the finder's construction call is unchanged.
    var userIntention: String = ""

    var allWindows: [WorkingTimingWindow] { [best] + alternatives }
}

// MARK: - Scorer (centralized, adjustable weights)

enum WorkingTimingScorer {

    /// All tunable scoring weights live here so they're easy to adjust later.
    struct Weights: Sendable {
        var planetaryHourRuler: Double = 6.0    // ruler matches the (narrow) planetary hour
        var planetaryDayRuler: Double = 3.0     // ruler matches the (broad) planetary day
        var favorableMoonPhase: Double = 4.0
        var favorableNumerology: Double = 3.0
        var favorableAspect: Double = 2.0       // a favorable aspect type is active
        var supportivePlanetPair: Double = 5.0  // an explicitly supportive pair is in transit
        var challengingPlanetPair: Double = -5.0
        var exactnessBonus: Double = 2.0        // scaled by transit exactness (0...1)
    }

    static let weights = Weights()

    static func score(_ c: WorkingTimingConditions, profile: WorkingTimingProfile) -> (score: Double, reasons: [WorkingTimingReason]) {
        var total = 0.0
        var reasons: [WorkingTimingReason] = []
        let w = weights

        let rulers = profile.planetaryRulers.compactMap { planet(from: $0) }

        // Planetary hour (narrower window → weighted higher than the day).
        if let hour = c.planetaryHour, rulers.contains(hour) {
            total += w.planetaryHourRuler
            reasons.append(WorkingTimingReason(
                text: "\(hour.displayName) rules this planetary hour — a ruling planet for this intention.",
                points: w.planetaryHourRuler))
        }

        // Planetary day.
        if rulers.contains(c.planetaryDay) {
            total += w.planetaryDayRuler
            reasons.append(WorkingTimingReason(
                text: "\(c.planetaryDay.displayName) rules this day — a ruling planet for this intention.",
                points: w.planetaryDayRuler))
        }

        // Favorable Moon phase.
        if matchesMoonPhase(c.moonPhase, favorable: profile.favorableMoonPhases) {
            total += w.favorableMoonPhase
            reasons.append(WorkingTimingReason(
                text: "The \(c.moonPhase) is a favorable Moon phase for this working.",
                points: w.favorableMoonPhase))
        }

        // Favorable numerology.
        if profile.favorableNumerologyNumbers.contains(c.numerology) {
            total += w.favorableNumerology
            reasons.append(WorkingTimingReason(
                text: "Universal Day \(c.numerology) matches a favorable numerology number.",
                points: w.favorableNumerology))
        }

        // Favorable aspect type — award the single closest matching transit so
        // many loose aspects can't inflate the score.
        let favoredAspects = Set(profile.favorableAspects.map { normalized($0) })
        if favoredAspects.isEmpty == false {
            let matching = c.transits.filter {
                favoredAspects.contains(normalized($0.aspect.rawValue)) ||
                favoredAspects.contains(normalized($0.aspect.displayName))
            }
            if let best = matching.max(by: { exactness($0) < exactness($1) }) {
                let pts = w.favorableAspect + w.exactnessBonus * 0.5 * exactness(best)
                total += pts
                reasons.append(WorkingTimingReason(
                    text: "A favorable \(best.aspect.displayName.lowercased()) is active — \(best.title).",
                    points: pts))
            }
        }

        // Supportive planet pairs (weighted more than a generic aspect match).
        for pair in profile.supportivePlanetPairs {
            if let transit = activeTransit(for: pair, in: c.transits) {
                let pts = w.supportivePlanetPair + w.exactnessBonus * exactness(transit)
                total += pts
                reasons.append(WorkingTimingReason(
                    text: "A supportive \(displayPair(pair)) transit is active — \(transit.title).",
                    points: pts))
            }
        }

        // Challenging planet pairs (negative).
        for pair in profile.challengingPlanetPairs {
            if let transit = activeTransit(for: pair, in: c.transits) {
                let pts = w.challengingPlanetPair - w.exactnessBonus * exactness(transit)
                total += pts
                reasons.append(WorkingTimingReason(
                    text: "A challenging \(displayPair(pair)) transit is active — \(transit.title).",
                    points: pts))
            }
        }

        return (total, reasons)
    }

    // MARK: Matching helpers

    /// 0...1, closer aspects score higher.
    static func exactness(_ transit: AstrologyTransit) -> Double {
        let orb = transit.aspect.defaultOrb
        guard orb > 0 else { return 0 }
        return max(0, 1 - transit.orb / orb)
    }

    static func planet(from name: String) -> Planet? {
        let key = normalized(name)
        return Planet.allCases.first { normalized($0.rawValue) == key || normalized($0.displayName) == key }
    }

    static func ephemerisBody(from name: String) -> EphemerisBody? {
        let key = normalized(name)
        return EphemerisBody.allCases.first { normalized($0.rawValue) == key || normalized($0.displayName) == key }
    }

    static func activeTransit(for pair: TimingPlanetPair, in transits: [AstrologyTransit]) -> AstrologyTransit? {
        guard let a = ephemerisBody(from: pair.first), let b = ephemerisBody(from: pair.second) else { return nil }
        let target: Set<EphemerisBody> = [a, b]
        return transits
            .filter { Set([$0.firstBody, $0.secondBody]) == target }
            .max(by: { exactness($0) < exactness($1) })
    }

    static func matchesMoonPhase(_ phase: String, favorable: [String]) -> Bool {
        let p = normalized(phase)
        return favorable.contains { fav in
            let f = normalized(fav)
            return p == f || p.contains(f) || f.contains(p)
        }
    }

    static func displayPair(_ pair: TimingPlanetPair) -> String {
        "\(pair.first.capitalized)–\(pair.second.capitalized)"
    }

    static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

// MARK: - Finder

struct WorkingTimingFinder {
    private let planetaryHourCalculator = PlanetaryHourCalculator()
    private let transitCalculator = AstrologyTransitCalculator()

    /// Searches the next `days` days and returns the best + two alternatives.
    /// Coordinates are passed as Doubles so the whole call is Sendable and can
    /// run off the main actor. Returns nil when no window has a positive score.
    func find(
        profile: WorkingTimingProfile,
        latitude: Double?,
        longitude: Double?,
        from startDate: Date = Date(),
        days: Int = 14,
        calendar: Calendar = .current
    ) -> WorkingTimingResult? {
        let windows = candidateConditions(
            latitude: latitude, longitude: longitude,
            startDate: startDate, days: days, calendar: calendar
        )
        guard windows.isEmpty == false else { return nil }

        var scored = windows.map { conditions -> WorkingTimingWindow in
            let result = WorkingTimingScorer.score(conditions, profile: profile)
            return WorkingTimingWindow(conditions: conditions, score: result.score, reasons: result.reasons, rank: 0)
        }

        scored.sort { $0.score > $1.score }
        guard let top = scored.first, top.score > 0 else { return nil }

        var ranked = Array(scored.prefix(3))
        for index in ranked.indices { ranked[index].rank = index + 1 }

        return WorkingTimingResult(
            profile: profile,
            best: ranked[0],
            alternatives: Array(ranked.dropFirst())
        )
    }

    // MARK: Candidate windows

    private struct DayConditions {
        let moonPhase: String
        let moonSign: String
        let numerology: Int
        let transits: [AstrologyTransit]
    }

    private func candidateConditions(
        latitude: Double?,
        longitude: Double?,
        startDate: Date,
        days: Int,
        calendar: Calendar
    ) -> [WorkingTimingConditions] {
        let timeZone = TimeZone.autoupdatingCurrent
        var cal = calendar
        cal.timeZone = timeZone
        let endDate = cal.date(byAdding: .day, value: days, to: startDate)
            ?? startDate.addingTimeInterval(Double(days) * 86_400)

        var dayCache: [String: DayConditions] = [:]
        var results: [WorkingTimingConditions] = []

        if let latitude, let longitude {
            // Preferred path: real planetary-hour windows.
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            var cursor = startDate
            var guardCounter = 0

            while cursor < endDate && guardCounter < 600 {
                guardCounter += 1
                guard let hour = try? planetaryHourCalculator.result(
                    at: cursor, coordinate: coordinate, timeZone: timeZone
                ) else {
                    cursor = cursor.addingTimeInterval(3_600)
                    continue
                }

                let day = dayConditions(for: hour.startTime, calendar: cal, cache: &dayCache)
                results.append(WorkingTimingConditions(
                    start: hour.startTime,
                    end: hour.endTime,
                    planetaryDay: hour.planetaryDay,
                    planetaryHour: hour.currentPlanet,
                    moonPhase: day.moonPhase,
                    moonSign: day.moonSign,
                    numerology: day.numerology,
                    transits: day.transits
                ))

                let next = hour.endTime.addingTimeInterval(1)
                if next <= cursor { break }
                cursor = next
            }
        } else {
            // Fallback (no location): one representative window per day, planetary
            // day only (planetary hours require a location).
            var dayStart = cal.startOfDay(for: startDate)
            for _ in 0..<days {
                let noon = cal.date(bySettingHour: 12, minute: 0, second: 0, of: dayStart) ?? dayStart
                let day = dayConditions(for: noon, calendar: cal, cache: &dayCache)
                results.append(WorkingTimingConditions(
                    start: cal.startOfDay(for: dayStart),
                    end: cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: dayStart)) ?? noon,
                    planetaryDay: DailySpiritualCalculator.planetaryDay(for: noon, calendar: cal),
                    planetaryHour: nil,
                    moonPhase: day.moonPhase,
                    moonSign: day.moonSign,
                    numerology: day.numerology,
                    transits: day.transits
                ))
                dayStart = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            }
        }

        return results
    }

    /// Per-day conditions (moon, numerology, transits) computed once and cached,
    /// since they don't change within a single day.
    private func dayConditions(
        for date: Date,
        calendar: Calendar,
        cache: inout [String: DayConditions]
    ) -> DayConditions {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let key = String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
        if let cached = cache[key] { return cached }

        let representative = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date) ?? date
        let moon = MoonPhaseCalculator.calculate(for: representative)
        let conditions = DayConditions(
            moonPhase: moon.phaseName,
            moonSign: moon.signName,
            numerology: NumerologyCalculator.universalDayNumber(for: representative, calendar: calendar),
            transits: transitCalculator.currentMajorTransits(for: representative)
        )
        cache[key] = conditions
        return conditions
    }
}
