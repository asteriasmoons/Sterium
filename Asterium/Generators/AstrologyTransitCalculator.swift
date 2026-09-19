//
//  AstrologyTransitCalculator.swift
//  Sterium
//

import Foundation

enum MajorAspect: String, CaseIterable, Codable, Sendable {
    case conjunction
    case sextile
    case square
    case trine
    case opposition

    var displayName: String { rawValue.capitalized }

    var tileLabel: String {
        switch self {
        case .conjunction: "CONJUNCT"
        case .sextile: "SEXTILE"
        case .square: "SQUARE"
        case .trine: "TRINE"
        case .opposition: "OPPOSITE"
        }
    }

    var assetName: String { rawValue }

    var angle: Double {
        switch self {
        case .conjunction: 0
        case .sextile: 60
        case .square: 90
        case .trine: 120
        case .opposition: 180
        }
    }

    var defaultOrb: Double {
        switch self {
        case .conjunction, .opposition: 6
        case .square, .trine: 5
        case .sextile: 4
        }
    }
}
struct AstrologyTransit: Equatable, Sendable, Identifiable, Codable {
    let firstBody: EphemerisBody
    let secondBody: EphemerisBody
    let aspect: MajorAspect
    let separation: Double
    let orb: Double
    let significance: Double

    var id: String {
        "\(firstBody.rawValue)-\(secondBody.rawValue)-\(aspect.rawValue)"
    }

    var title: String {
        "\(firstBody.displayName) \(aspect.displayName) \(secondBody.displayName)"
    }
}

struct RetrogradeEvent: Equatable, Sendable, Identifiable {
    let body: EphemerisBody
    let longitude: Double
    let significance: Double

    var id: String { body.rawValue }
    var title: String { "\(body.displayName) Retrograde" }
}

struct AstrologyTransitCalculator: Sendable {
    let ephemeris: EphemerisEngine

    init(ephemeris: EphemerisEngine = EphemerisEngine()) {
        self.ephemeris = ephemeris
    }
    func currentRetrogrades(for date: Date = Date()) -> [RetrogradeEvent] {
        let snapshot = ephemeris.snapshot(for: date)

        return snapshot.positions.values
            .filter { $0.isRetrograde }
            .map {
                RetrogradeEvent(
                    body: $0.body,
                    longitude: $0.longitude,
                    significance: bodyWeight($0.body)
                )
            }
            .sorted { $0.significance > $1.significance }
    }

    func currentMajorTransits(
        for date: Date = Date(),
        includeMoon: Bool = false
    ) -> [AstrologyTransit] {
        let snapshot = ephemeris.snapshot(for: date)
        let bodies = EphemerisBody.allCases.filter {
            $0 != .moon || includeMoon
        }

        var transits: [AstrologyTransit] = []

        for firstIndex in 0..<bodies.count {
            for secondIndex in (firstIndex + 1)..<bodies.count {
                let firstBody = bodies[firstIndex]
                let secondBody = bodies[secondIndex]
                guard
                    let first = snapshot[firstBody],
                    let second = snapshot[secondBody]
                else { continue }

                let separation = angularSeparation(first.longitude, second.longitude)

                for aspect in MajorAspect.allCases {
                    let orb = abs(separation - aspect.angle)
                    guard orb <= aspect.defaultOrb else { continue }

                    let exactness = max(0, 1 - orb / aspect.defaultOrb)
                    let significance =
                        aspectWeight(aspect) +
                        bodyWeight(firstBody) +
                        bodyWeight(secondBody) +
                        exactness * 3

                    transits.append(
                        AstrologyTransit(
                            firstBody: firstBody,
                            secondBody: secondBody,
                            aspect: aspect,
                            separation: separation,
                            orb: orb,
                            significance: significance
                        )
                    )
                }
            }
        }
        return transits.sorted {
            if $0.significance == $1.significance {
                return $0.orb < $1.orb
            }
            return $0.significance > $1.significance
        }
    }

    func homeScreenEvents(for date: Date = Date()) -> (retrograde: RetrogradeEvent?, transits: [AstrologyTransit]) {
        let retrograde = currentRetrogrades(for: date).first
        let transits = Array(currentMajorTransits(for: date).prefix(3))
        return (retrograde, transits)
    }

    private func angularSeparation(_ first: Double, _ second: Double) -> Double {
        let raw = abs(first - second).truncatingRemainder(dividingBy: 360)
        return raw > 180 ? 360 - raw : raw
    }

    private func aspectWeight(_ aspect: MajorAspect) -> Double {
        switch aspect {
        case .conjunction: 5.0
        case .opposition: 5.0
        case .square: 4.5
        case .trine: 4.0
        case .sextile: 3.0
        }
    }
    private func bodyWeight(_ body: EphemerisBody) -> Double {
        switch body {
        case .sun: 5.0
        case .mercury, .venus, .mars: 3.5
        case .jupiter, .saturn: 4.5
        case .uranus, .neptune: 4.0
        case .moon: 2.0
        }
    }
}
