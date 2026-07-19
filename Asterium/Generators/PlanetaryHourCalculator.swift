//
//  PlanetaryHourCalculator.swift
//  Asterium
//

import Foundation
import CoreLocation

struct PlanetaryHourCalculator: Sendable {
    private let solarCalculator: SolarCalculator

    init(solarCalculator: SolarCalculator = SolarCalculator()) {
        self.solarCalculator = solarCalculator
    }

    func result(
        at date: Date = Date(),
        coordinate: CLLocationCoordinate2D,
        timeZone: TimeZone = .autoupdatingCurrent
    ) throws -> PlanetaryHourResult {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        guard
            let todayStart = calendar.date(
                from: calendar.dateComponents([.year, .month, .day], from: date)
            ),
            let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: todayStart
            ),
            let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: todayStart
            )
        else {
            throw PlanetaryHourError.invalidSolarInterval
        }

        guard let todayEvents = solarCalculator.events(
            for: todayStart,
            coordinate: coordinate,
            timeZone: timeZone
        ) else {
            throw PlanetaryHourError.solarEventUnavailable
        }

        let dayStartDate: Date
        let sunrise: Date
        let sunset: Date
        let nextSunrise: Date

        if date >= todayEvents.sunrise {
            guard let nextEvents = solarCalculator.events(
                for: nextDay,
                coordinate: coordinate,
                timeZone: timeZone
            ) else {
                throw PlanetaryHourError.solarEventUnavailable
            }

            dayStartDate = todayStart
            sunrise = todayEvents.sunrise
            sunset = todayEvents.sunset
            nextSunrise = nextEvents.sunrise
        } else {
            guard let previousEvents = solarCalculator.events(
                for: previousDay,
                coordinate: coordinate,
                timeZone: timeZone
            ) else {
                throw PlanetaryHourError.solarEventUnavailable
            }

            dayStartDate = previousDay
            sunrise = previousEvents.sunrise
            sunset = previousEvents.sunset
            nextSunrise = todayEvents.sunrise
        }

        guard sunrise < sunset, sunset < nextSunrise else {
            throw PlanetaryHourError.invalidSolarInterval
        }

        let weekday = calendar.component(.weekday, from: dayStartDate)
        let planetaryDay = Planet.ruler(for: weekday)

        guard let startingIndex = Planet.chaldeanOrder.firstIndex(
            of: planetaryDay
        ) else {
            throw PlanetaryHourError.invalidSolarInterval
        }

        let isDaytime = date < sunset
        let period: PlanetaryPeriod = isDaytime ? .day : .night
        let periodStart = isDaytime ? sunrise : sunset
        let periodEnd = isDaytime ? sunset : nextSunrise
        let periodDuration = periodEnd.timeIntervalSince(periodStart)
        let hourDuration = periodDuration / 12.0

        guard hourDuration > 0 else {
            throw PlanetaryHourError.invalidSolarInterval
        }

        let elapsed = max(date.timeIntervalSince(periodStart), 0)
        let periodIndex = min(
            max(Int(floor(elapsed / hourDuration)), 0),
            11
        )
        let absoluteHourIndex = isDaytime ? periodIndex : periodIndex + 12

        let planetIndex =
            (startingIndex + absoluteHourIndex) %
            Planet.chaldeanOrder.count

        let nextPlanetIndex =
            (planetIndex + 1) %
            Planet.chaldeanOrder.count

        let startTime = periodStart.addingTimeInterval(
            Double(periodIndex) * hourDuration
        )

        let endTime = periodStart.addingTimeInterval(
            Double(periodIndex + 1) * hourDuration
        )

        return PlanetaryHourResult(
            planetaryDay: planetaryDay,
            currentPlanet: Planet.chaldeanOrder[planetIndex],
            hourNumber: absoluteHourIndex + 1,
            periodHourNumber: periodIndex + 1,
            period: period,
            startTime: startTime,
            endTime: endTime,
            nextPlanet: Planet.chaldeanOrder[nextPlanetIndex],
            nextChangeTime: endTime,
            sunrise: sunrise,
            sunset: sunset,
            nextSunrise: nextSunrise
        )
    }
}
