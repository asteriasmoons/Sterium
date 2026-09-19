//
//  MoonRiseSetCalculator.swift
//  Sterium
//

import Foundation
import CoreLocation

struct MoonRiseSetResult: Equatable, Sendable {
    let moonrise: Date?
    let moonset: Date?
}

struct MoonRiseSetCalculator: Sendable {
    private let standardAltitude = 0.125
    private let searchStep: TimeInterval = 600
    private let refinementCount = 16

    func result(
        for date: Date = Date(),
        coordinate: CLLocationCoordinate2D,
        timeZone: TimeZone = .autoupdatingCurrent
    ) -> MoonRiseSetResult? {
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        guard
            let dayStart = calendar.date(
                from: calendar.dateComponents([.year, .month, .day], from: date)
            ),
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)
        else {
            return nil
        }

        var moonrise: Date?
        var moonset: Date?
        var previousDate = dayStart
        var previousAltitude = altitudeDifference(
            at: previousDate,
            coordinate: coordinate
        )

        var sampleDate = dayStart.addingTimeInterval(searchStep)

        while sampleDate <= dayEnd {
            let currentAltitude = altitudeDifference(
                at: sampleDate,
                coordinate: coordinate
            )

            if previousAltitude <= 0, currentAltitude > 0, moonrise == nil {
                moonrise = refinedCrossing(
                    from: previousDate,
                    to: sampleDate,
                    coordinate: coordinate
                )
            } else if previousAltitude >= 0, currentAltitude < 0, moonset == nil {
                moonset = refinedCrossing(
                    from: previousDate,
                    to: sampleDate,
                    coordinate: coordinate
                )
            }

            if moonrise != nil, moonset != nil {
                break
            }

            previousDate = sampleDate
            previousAltitude = currentAltitude
            sampleDate = sampleDate.addingTimeInterval(searchStep)
        }

        return MoonRiseSetResult(moonrise: moonrise, moonset: moonset)
    }

    private func refinedCrossing(
        from startDate: Date,
        to endDate: Date,
        coordinate: CLLocationCoordinate2D
    ) -> Date {
        var lowerDate = startDate
        var upperDate = endDate
        let lowerStartsBelow = altitudeDifference(
            at: lowerDate,
            coordinate: coordinate
        ) <= 0

        for _ in 0..<refinementCount {
            let midpoint = Date(
                timeIntervalSince1970:
                    (lowerDate.timeIntervalSince1970 + upperDate.timeIntervalSince1970) / 2
            )
            let midpointIsBelow = altitudeDifference(
                at: midpoint,
                coordinate: coordinate
            ) <= 0

            if midpointIsBelow == lowerStartsBelow {
                lowerDate = midpoint
            } else {
                upperDate = midpoint
            }
        }

        return Date(
            timeIntervalSince1970:
                (lowerDate.timeIntervalSince1970 + upperDate.timeIntervalSince1970) / 2
        )
    }

    private func altitudeDifference(
        at date: Date,
        coordinate: CLLocationCoordinate2D
    ) -> Double {
        moonAltitude(at: date, coordinate: coordinate) - standardAltitude
    }

    private func moonAltitude(
        at date: Date,
        coordinate: CLLocationCoordinate2D
    ) -> Double {
        let position = moonEquatorialPosition(at: date)
        let julianDay = date.timeIntervalSince1970 / 86_400 + 2_440_587.5
        let siderealTime = localSiderealTimeDegrees(
            julianDay: julianDay,
            longitude: coordinate.longitude
        )
        let hourAngle = normalizedDegrees(siderealTime - position.rightAscension)
        let latitude = degreesToRadians(coordinate.latitude)
        let declination = degreesToRadians(position.declination)
        let hourAngleRadians = degreesToRadians(hourAngle)

        let sinAltitude =
            sin(latitude) * sin(declination) +
            cos(latitude) * cos(declination) * cos(hourAngleRadians)

        return radiansToDegrees(asin(min(max(sinAltitude, -1), 1)))
    }

    private func moonEquatorialPosition(
        at date: Date
    ) -> (rightAscension: Double, declination: Double) {
        let julianDay = date.timeIntervalSince1970 / 86_400 + 2_440_587.5
        let days = julianDay - 2_451_545.0

        let meanLongitude = normalizedDegrees(218.316 + 13.176396 * days)
        let meanAnomaly = normalizedDegrees(134.963 + 13.064993 * days)
        let meanElongation = normalizedDegrees(297.850 + 12.190749 * days)
        let argumentOfLatitude = normalizedDegrees(93.272 + 13.229350 * days)

        let longitude = normalizedDegrees(
            meanLongitude +
            6.289 * sinDegrees(meanAnomaly) +
            1.274 * sinDegrees(2 * meanElongation - meanAnomaly) +
            0.658 * sinDegrees(2 * meanElongation) +
            0.214 * sinDegrees(2 * meanAnomaly)
        )
        let latitude =
            5.128 * sinDegrees(argumentOfLatitude) +
            0.280 * sinDegrees(meanAnomaly + argumentOfLatitude) +
            0.277 * sinDegrees(meanAnomaly - argumentOfLatitude) +
            0.173 * sinDegrees(2 * meanElongation - argumentOfLatitude)

        let obliquity = 23.439291 - 0.00000036 * days
        let longitudeRadians = degreesToRadians(longitude)
        let latitudeRadians = degreesToRadians(latitude)
        let obliquityRadians = degreesToRadians(obliquity)

        let rightAscension = radiansToDegrees(
            atan2(
                sin(longitudeRadians) * cos(obliquityRadians) -
                    tan(latitudeRadians) * sin(obliquityRadians),
                cos(longitudeRadians)
            )
        )
        let declination = radiansToDegrees(
            asin(
                sin(latitudeRadians) * cos(obliquityRadians) +
                    cos(latitudeRadians) * sin(obliquityRadians) * sin(longitudeRadians)
            )
        )

        return (normalizedDegrees(rightAscension), declination)
    }

    private func localSiderealTimeDegrees(
        julianDay: Double,
        longitude: Double
    ) -> Double {
        let days = julianDay - 2_451_545.0
        return normalizedDegrees(
            280.46061837 +
            360.98564736629 * days +
            longitude
        )
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        let normalized = value.truncatingRemainder(dividingBy: 360)
        return normalized < 0 ? normalized + 360 : normalized
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
}
