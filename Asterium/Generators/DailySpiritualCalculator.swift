//
//  DailySpiritualCalculator.swift
//  Asterium
//

import Foundation

struct SabbatInfo: Equatable {
    let name: String
    let date: Date
    let description: String

    func countdown(from date: Date = Date(), calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let target = calendar.startOfDay(for: self.date)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }
}

struct DailyCorrespondences: Equatable {
    let planet: Planet
    let element: String
    let color: String
    let crystal: String
    let herb: String
}

struct LuckyHour: Identifiable, Equatable {
    let id = UUID()
    let purpose: String
    let planet: Planet
    let startTime: Date?
    let endTime: Date?

    var timeRangeText: String {
        guard let startTime, let endTime else { return "Location needed" }
        return "\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
    }
}

struct PlanetaryHourInterval: Equatable {
    let planet: Planet
    let startTime: Date
    let endTime: Date
}

struct DailySpiritualCalculator {
    static func weekdayName(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let weekday = calendar.component(.weekday, from: date)
        return calendar.weekdaySymbols[weekday - 1]
    }

    static func planetaryDay(for date: Date = Date(), calendar: Calendar = .current) -> Planet {
        Planet.ruler(for: calendar.component(.weekday, from: date))
    }

    static func correspondences(for planet: Planet) -> DailyCorrespondences {
        switch planet {
        case .sun:
            DailyCorrespondences(
                planet: planet,
                element: "Fire",
                color: "Gold",
                crystal: "Citrine",
                herb: "Calendula"
            )
        case .moon:
            DailyCorrespondences(
                planet: planet,
                element: "Water",
                color: "Silver",
                crystal: "Moonstone",
                herb: "Mugwort"
            )
        case .mars:
            DailyCorrespondences(
                planet: planet,
                element: "Fire",
                color: "Red",
                crystal: "Carnelian",
                herb: "Nettle"
            )
        case .mercury:
            DailyCorrespondences(
                planet: planet,
                element: "Air",
                color: "Yellow",
                crystal: "Fluorite",
                herb: "Lavender"
            )
        case .jupiter:
            DailyCorrespondences(
                planet: planet,
                element: "Air",
                color: "Royal Blue",
                crystal: "Amethyst",
                herb: "Sage"
            )
        case .venus:
            DailyCorrespondences(
                planet: planet,
                element: "Water",
                color: "Green",
                crystal: "Rose Quartz",
                herb: "Rose"
            )
        case .saturn:
            DailyCorrespondences(
                planet: planet,
                element: "Earth",
                color: "Black",
                crystal: "Obsidian",
                herb: "Comfrey"
            )
        }
    }

    static func nextSabbat(from date: Date = Date(), calendar: Calendar = .current) -> SabbatInfo {
        let year = calendar.component(.year, from: date)
        let sabbats = sabbats(for: year, calendar: calendar) +
            sabbats(for: year + 1, calendar: calendar)

        return sabbats
            .sorted { $0.date < $1.date }
            .first { calendar.startOfDay(for: $0.date) >= calendar.startOfDay(for: date) }!
    }

    static func luckyHours(
        from result: PlanetaryHourResult?,
        now: Date = Date()
    ) -> [LuckyHour] {
        let targets: [(String, Planet)] = [
            ("Manifestation", .jupiter),
            ("Meditation", .moon),
            ("Divination", .mercury),
            ("Cleansing", .saturn)
        ]

        guard let result else {
            return targets.map {
                LuckyHour(
                    purpose: $0.0,
                    planet: $0.1,
                    startTime: nil,
                    endTime: nil
                )
            }
        }

        let intervals = intervals(for: result)

        return targets.map { target in
            let match = intervals.first {
                $0.planet == target.1 && $0.endTime >= now
            } ?? intervals.first { $0.planet == target.1 }

            return LuckyHour(
                purpose: target.0,
                planet: target.1,
                startTime: match?.startTime,
                endTime: match?.endTime
            )
        }
    }

    private static func intervals(
        for result: PlanetaryHourResult
    ) -> [PlanetaryHourInterval] {
        guard
            let startIndex = Planet.chaldeanOrder.firstIndex(
                of: result.planetaryDay
            )
        else {
            return []
        }

        let dayDuration = result.sunset.timeIntervalSince(result.sunrise) / 12.0
        let nightDuration = result.nextSunrise.timeIntervalSince(result.sunset) / 12.0

        guard dayDuration > 0, nightDuration > 0 else { return [] }

        var intervals: [PlanetaryHourInterval] = []

        for hour in 0..<24 {
            let isDayHour = hour < 12
            let periodIndex = isDayHour ? hour : hour - 12
            let periodStart = isDayHour ? result.sunrise : result.sunset
            let duration = isDayHour ? dayDuration : nightDuration
            let planetIndex = (startIndex + hour) % Planet.chaldeanOrder.count
            let start = periodStart.addingTimeInterval(Double(periodIndex) * duration)
            let end = periodStart.addingTimeInterval(Double(periodIndex + 1) * duration)

            intervals.append(
                PlanetaryHourInterval(
                    planet: Planet.chaldeanOrder[planetIndex],
                    startTime: start,
                    endTime: end
                )
            )
        }

        return intervals
    }

    private static func sabbats(
        for year: Int,
        calendar: Calendar
    ) -> [SabbatInfo] {
        [
            sabbat("Imbolc", year, 2, 1, "A threshold for purification, early light, and renewal.", calendar),
            sabbat("Ostara", year, 3, 20, "Balance, awakening, and the first bright signs of growth.", calendar),
            sabbat("Beltane", year, 5, 1, "A fire festival for pleasure, vitality, and creative bloom.", calendar),
            sabbat("Litha", year, 6, 21, "The solar peak for courage, radiance, and celebration.", calendar),
            sabbat("Lammas", year, 8, 1, "The first harvest, honoring skill, gratitude, and devotion.", calendar),
            sabbat("Mabon", year, 9, 22, "A balance point for harvest, reflection, and reciprocity.", calendar),
            sabbat("Samhain", year, 10, 31, "A veil-thin night for remembrance, release, and ancestral work.", calendar),
            sabbat("Yule", year, 12, 21, "The longest night, returning light, and deep restoration.", calendar)
        ]
    }

    private static func sabbat(
        _ name: String,
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ description: String,
        _ calendar: Calendar
    ) -> SabbatInfo {
        let date = calendar.date(
            from: DateComponents(year: year, month: month, day: day)
        )!

        return SabbatInfo(name: name, date: date, description: description)
    }
}
