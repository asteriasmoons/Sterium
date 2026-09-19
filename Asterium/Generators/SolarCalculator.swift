//
//  SolarCalculator.swift
//  Sterium
//

import Foundation
import CoreLocation

struct SolarEvents: Equatable, Sendable {
    let sunrise: Date
    let sunset: Date
}

struct SolarCalculator: Sendable {
    private let officialZenith = 90.833

    func events(
        for date: Date,
        coordinate: CLLocationCoordinate2D,
        timeZone: TimeZone
    ) -> SolarEvents? {
        guard
            let sunrise = solarEvent(
                for: date,
                coordinate: coordinate,
                timeZone: timeZone,
                isSunrise: true
            ),
            let sunset = solarEvent(
                for: date,
                coordinate: coordinate,
                timeZone: timeZone,
                isSunrise: false
            )
        else {
            return nil
        }

        return SolarEvents(sunrise: sunrise, sunset: sunset)
    }

    private func solarEvent(
        for date: Date,
        coordinate: CLLocationCoordinate2D,
        timeZone: TimeZone,
        isSunrise: Bool
    ) -> Date? {
        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = timeZone

        let components = localCalendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        guard
            let year = components.year,
            let month = components.month,
            let day = components.day,
            let localMidnight = localCalendar.date(
                from: DateComponents(year: year, month: month, day: day)
            ),
            let dayOfYear = localCalendar.ordinality(
                of: .day,
                in: .year,
                for: localMidnight
            )
        else {
            return nil
        }

        let longitudeHour = coordinate.longitude / 15.0
        let approximateTime = Double(dayOfYear) +
            ((isSunrise ? 6.0 : 18.0) - longitudeHour) / 24.0

        let meanAnomaly = (0.9856 * approximateTime) - 3.289

        var trueLongitude = meanAnomaly +
            (1.916 * sinDegrees(meanAnomaly)) +
            (0.020 * sinDegrees(2 * meanAnomaly)) +
            282.634
        trueLongitude = normalizedDegrees(trueLongitude)

        var rightAscension = atanDegrees(0.91764 * tanDegrees(trueLongitude))
        rightAscension = normalizedDegrees(rightAscension)

        let longitudeQuadrant = floor(trueLongitude / 90.0) * 90.0
        let rightAscensionQuadrant = floor(rightAscension / 90.0) * 90.0
        rightAscension += longitudeQuadrant - rightAscensionQuadrant
        rightAscension /= 15.0

        let sinDeclination = 0.39782 * sinDegrees(trueLongitude)
        let cosDeclination = cos(asin(sinDeclination))

        let latitudeRadians = degreesToRadians(coordinate.latitude)

        let cosHourAngle =
            (cosDegrees(officialZenith) -
             (sinDeclination * sin(latitudeRadians))) /
            (cosDeclination * cos(latitudeRadians))

        guard (-1.0...1.0).contains(cosHourAngle) else {
            return nil
        }

        var localHourAngle = isSunrise
            ? 360.0 - acosDegrees(cosHourAngle)
            : acosDegrees(cosHourAngle)

        localHourAngle /= 15.0

        let localMeanTime =
            localHourAngle +
            rightAscension -
            (0.06571 * approximateTime) -
            6.622

        let rawUniversalTime = localMeanTime - longitudeHour
        let universalDayOffset = Int(floor(rawUniversalTime / 24.0))
        let normalizedUniversalTime = normalizedHours(rawUniversalTime)

        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!

        guard
            let utcMidnight = utcCalendar.date(
                from: DateComponents(year: year, month: month, day: day)
            ),
            let adjustedUniversalDate = utcCalendar.date(
                byAdding: .day,
                value: universalDayOffset,
                to: utcMidnight
            ),
            let nextLocalMidnight = localCalendar.date(
                byAdding: .day,
                value: 1,
                to: localMidnight
            )
        else {
            return nil
        }

        var eventDate = adjustedUniversalDate.addingTimeInterval(
            normalizedUniversalTime * 3_600
        )

        while eventDate < localMidnight {
            eventDate = eventDate.addingTimeInterval(86_400)
        }

        while eventDate >= nextLocalMidnight {
            eventDate = eventDate.addingTimeInterval(-86_400)
        }

        return eventDate
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        let result = value.truncatingRemainder(dividingBy: 360)
        return result < 0 ? result + 360 : result
    }

    private func normalizedHours(_ value: Double) -> Double {
        let result = value.truncatingRemainder(dividingBy: 24)
        return result < 0 ? result + 24 : result
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }

    private func sinDegrees(_ degrees: Double) -> Double {
        sin(degreesToRadians(degrees))
    }

    private func cosDegrees(_ degrees: Double) -> Double {
        cos(degreesToRadians(degrees))
    }

    private func tanDegrees(_ degrees: Double) -> Double {
        tan(degreesToRadians(degrees))
    }

    private func atanDegrees(_ value: Double) -> Double {
        radiansToDegrees(atan(value))
    }

    private func acosDegrees(_ value: Double) -> Double {
        radiansToDegrees(acos(value))
    }
}
