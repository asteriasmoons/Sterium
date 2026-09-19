//
//  EphemerisEngine.swift
//  Sterium
//

import Foundation

enum EphemerisBody: String, CaseIterable, Codable, Sendable {
    case sun, mercury, venus, mars, jupiter, saturn, uranus, neptune, moon

    var displayName: String { rawValue.capitalized }

    var canRetrograde: Bool {
        switch self {
        case .mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune: true
        case .sun, .moon: false
        }
    }
}

struct EphemerisPosition: Equatable, Sendable {
    let body: EphemerisBody
    let longitude: Double
    let latitude: Double
    let distanceAU: Double
    let isRetrograde: Bool
}
struct EphemerisSnapshot: Equatable, Sendable {
    let date: Date
    let positions: [EphemerisBody: EphemerisPosition]

    subscript(_ body: EphemerisBody) -> EphemerisPosition? {
        positions[body]
    }
}

struct EphemerisEngine: Sendable {
    private struct Elements {
        let a0, aRate: Double
        let e0, eRate: Double
        let i0, iRate: Double
        let l0, lRate: Double
        let peri0, periRate: Double
        let node0, nodeRate: Double
    }

    private struct Vector3 {
        let x: Double
        let y: Double
        let z: Double

        static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
            Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
        }
    }
    func snapshot(for date: Date = Date()) -> EphemerisSnapshot {
        var result: [EphemerisBody: EphemerisPosition] = [:]

        for body in EphemerisBody.allCases {
            if let position = position(of: body, at: date) {
                result[body] = position
            }
        }

        return EphemerisSnapshot(date: date, positions: result)
    }

    func position(of body: EphemerisBody, at date: Date = Date()) -> EphemerisPosition? {
        if body == .moon {
            let longitude = MoonPhaseCalculator.getMoonEclipticLongitude(for: date)
            return EphemerisPosition(
                body: .moon,
                longitude: longitude,
                latitude: 0,
                distanceAU: 0.00257,
                isRetrograde: false
            )
        }

        guard let coordinates = geocentricCoordinates(of: body, at: date) else { return nil }
        let longitude = normalizedDegrees(radiansToDegrees(atan2(coordinates.y, coordinates.x)))
        let latitude = radiansToDegrees(atan2(coordinates.z, hypot(coordinates.x, coordinates.y)))
        let distance = sqrt(coordinates.x * coordinates.x + coordinates.y * coordinates.y + coordinates.z * coordinates.z)
        let retrograde = body.canRetrograde ? isRetrograde(body, at: date) : false
        return EphemerisPosition(
            body: body,
            longitude: longitude,
            latitude: latitude,
            distanceAU: distance,
            isRetrograde: retrograde
        )
    }

    private func geocentricCoordinates(of body: EphemerisBody, at date: Date) -> Vector3? {
        let centuries = julianCenturies(for: date)
        guard let earth = heliocentricCoordinates(for: .sun, centuries: centuries) else { return nil }

        if body == .sun {
            return Vector3(x: -earth.x, y: -earth.y, z: -earth.z)
        }

        guard let planet = heliocentricCoordinates(for: body, centuries: centuries) else { return nil }
        return planet - earth
    }

    private func isRetrograde(_ body: EphemerisBody, at date: Date) -> Bool {
        let interval: TimeInterval = 43_200
        guard
            let before = rawGeocentricLongitude(of: body, at: date.addingTimeInterval(-interval)),
            let after = rawGeocentricLongitude(of: body, at: date.addingTimeInterval(interval))
        else { return false }

        return signedAngularDifference(from: before, to: after) < 0
    }
    private func rawGeocentricLongitude(of body: EphemerisBody, at date: Date) -> Double? {
        guard let coordinates = geocentricCoordinates(of: body, at: date) else { return nil }
        return normalizedDegrees(radiansToDegrees(atan2(coordinates.y, coordinates.x)))
    }

    private func heliocentricCoordinates(for body: EphemerisBody, centuries: Double) -> Vector3? {
        let elements: Elements
        if body == .sun {
            elements = Self.earthElements
        } else {
            guard let found = Self.planetElements[body] else { return nil }
            elements = found
        }

        let a = elements.a0 + elements.aRate * centuries
        let e = elements.e0 + elements.eRate * centuries
        let inclination = elements.i0 + elements.iRate * centuries
        let meanLongitude = elements.l0 + elements.lRate * centuries
        let longitudePerihelion = elements.peri0 + elements.periRate * centuries
        let longitudeNode = elements.node0 + elements.nodeRate * centuries
        let argumentPerihelion = longitudePerihelion - longitudeNode
        let meanAnomaly = normalizedSignedDegrees(meanLongitude - longitudePerihelion)
        let eccentricAnomaly = solveKepler(meanAnomalyDegrees: meanAnomaly, eccentricity: e)

        let eccentricAnomalyRadians = degreesToRadians(eccentricAnomaly)
        let xPrime = a * (cos(eccentricAnomalyRadians) - e)
        let yPrime = a * sqrt(1 - e * e) * sin(eccentricAnomalyRadians)
        let omega = degreesToRadians(argumentPerihelion)
        let node = degreesToRadians(longitudeNode)
        let i = degreesToRadians(inclination)

        let x =
            (cos(omega) * cos(node) - sin(omega) * sin(node) * cos(i)) * xPrime +
            (-sin(omega) * cos(node) - cos(omega) * sin(node) * cos(i)) * yPrime

        let y =
            (cos(omega) * sin(node) + sin(omega) * cos(node) * cos(i)) * xPrime +
            (-sin(omega) * sin(node) + cos(omega) * cos(node) * cos(i)) * yPrime

        let z =
            (sin(omega) * sin(i)) * xPrime +
            (cos(omega) * sin(i)) * yPrime

        return Vector3(x: x, y: y, z: z)
    }

    private func solveKepler(meanAnomalyDegrees: Double, eccentricity: Double) -> Double {
        let eStar = radiansToDegrees(eccentricity)
        var eccentricAnomaly = meanAnomalyDegrees + eStar * sin(degreesToRadians(meanAnomalyDegrees))

        for _ in 0..<12 {
            let eRadians = degreesToRadians(eccentricAnomaly)
            let deltaM = meanAnomalyDegrees - (eccentricAnomaly - eStar * sin(eRadians))
            let deltaE = deltaM / (1 - eccentricity * cos(eRadians))
            eccentricAnomaly += deltaE
            if abs(deltaE) <= 0.000001 { break }
        }

        return eccentricAnomaly
    }
    private func julianCenturies(for date: Date) -> Double {
        let julianDay = date.timeIntervalSince1970 / 86_400 + 2_440_587.5
        return (julianDay - 2_451_545.0) / 36_525.0
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        let result = value.truncatingRemainder(dividingBy: 360)
        return result < 0 ? result + 360 : result
    }

    private func normalizedSignedDegrees(_ value: Double) -> Double {
        var result = normalizedDegrees(value)
        if result > 180 { result -= 360 }
        return result
    }

    private func signedAngularDifference(from start: Double, to end: Double) -> Double {
        normalizedSignedDegrees(end - start)
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }

    private static let earthElements = Elements(
        a0: 1.00000261, aRate: 0.00000562,
        e0: 0.01671123, eRate: -0.00004392,
        i0: -0.00001531, iRate: -0.01294668,
        l0: 100.46457166, lRate: 35999.37244981,
        peri0: 102.93768193, periRate: 0.32327364,
        node0: 0.0, nodeRate: 0.0
    )
    private static let planetElements: [EphemerisBody: Elements] = [
        .mercury: Elements(
            a0: 0.38709927, aRate: 0.00000037,
            e0: 0.20563593, eRate: 0.00001906,
            i0: 7.00497902, iRate: -0.00594749,
            l0: 252.25032350, lRate: 149472.67411175,
            peri0: 77.45779628, periRate: 0.16047689,
            node0: 48.33076593, nodeRate: -0.12534081
        ),
        .venus: Elements(
            a0: 0.72333566, aRate: 0.00000390,
            e0: 0.00677672, eRate: -0.00004107,
            i0: 3.39467605, iRate: -0.00078890,
            l0: 181.97909950, lRate: 58517.81538729,
            peri0: 131.60246718, periRate: 0.00268329,
            node0: 76.67984255, nodeRate: -0.27769418
        ),
        .mars: Elements(
            a0: 1.52371034, aRate: 0.00001847,
            e0: 0.09339410, eRate: 0.00007882,
            i0: 1.84969142, iRate: -0.00813131,
            l0: -4.55343205, lRate: 19140.30268499,
            peri0: -23.94362959, periRate: 0.44441088,
            node0: 49.55953891, nodeRate: -0.29257343
        ),
        .jupiter: Elements(
            a0: 5.20288700, aRate: -0.00011607,
            e0: 0.04838624, eRate: -0.00013253,
            i0: 1.30439695, iRate: -0.00183714,
            l0: 34.39644051, lRate: 3034.74612775,
            peri0: 14.72847983, periRate: 0.21252668,
            node0: 100.47390909, nodeRate: 0.20469106
        ),
        .saturn: Elements(
            a0: 9.53667594, aRate: -0.00125060,
            e0: 0.05386179, eRate: -0.00050991,
            i0: 2.48599187, iRate: 0.00193609,
            l0: 49.95424423, lRate: 1222.49362201,
            peri0: 92.59887831, periRate: -0.41897216,
            node0: 113.66242448, nodeRate: -0.28867794
        ),
        .uranus: Elements(
            a0: 19.18916464, aRate: -0.00196176,
            e0: 0.04725744, eRate: -0.00004397,
            i0: 0.77263783, iRate: -0.00242939,
            l0: 313.23810451, lRate: 428.48202785,
            peri0: 170.95427630, periRate: 0.40805281,
            node0: 74.01692503, nodeRate: 0.04240589
        ),
        .neptune: Elements(
            a0: 30.06992276, aRate: 0.00026291,
            e0: 0.00859048, eRate: 0.00005105,
            i0: 1.77004347, iRate: 0.00035372,
            l0: -55.12002969, lRate: 218.45945325,
            peri0: 44.96476227, periRate: -0.32241464,
            node0: 131.78422574, nodeRate: -0.00508664
        )
    ]
}
