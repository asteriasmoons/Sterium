//
//  Planet.swift
//  Sterium
//

import Foundation

enum Planet: String, CaseIterable, Codable, Identifiable, Sendable {
    case saturn, jupiter, mars, sun, venus, mercury, moon

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .saturn: "♄"
        case .jupiter: "♃"
        case .mars: "♂"
        case .sun: "☉"
        case .venus: "♀"
        case .mercury: "☿"
        case .moon: "☽"
        }
    }

    var keywords: String {
        switch self {
        case .saturn: "Discipline, boundaries, patience"
        case .jupiter: "Growth, wisdom, abundance"
        case .mars: "Action, courage, protection"
        case .sun: "Vitality, success, confidence"
        case .venus: "Love, beauty, harmony"
        case .mercury: "Communication, learning, travel"
        case .moon: "Intuition, emotion, reflection"
        }
    }

    static let chaldeanOrder: [Planet] = [
        .saturn, .jupiter, .mars, .sun, .venus, .mercury, .moon
    ]

    static func ruler(for weekday: Int) -> Planet {
        switch weekday {
        case 1: .sun
        case 2: .moon
        case 3: .mars
        case 4: .mercury
        case 5: .jupiter
        case 6: .venus
        case 7: .saturn
        default: .sun
        }
    }
}

enum PlanetaryPeriod: String, Codable, Sendable {
    case day
    case night

    var displayName: String { rawValue.capitalized }
}

struct PlanetaryHourResult: Equatable, Sendable {
    let planetaryDay: Planet
    let currentPlanet: Planet
    let hourNumber: Int
    let periodHourNumber: Int
    let period: PlanetaryPeriod
    let startTime: Date
    let endTime: Date
    let nextPlanet: Planet
    let nextChangeTime: Date
    let sunrise: Date
    let sunset: Date
    let nextSunrise: Date
}

enum PlanetaryHourError: LocalizedError, Equatable {
    case locationUnavailable
    case solarEventUnavailable
    case invalidSolarInterval

    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            "A location is needed to calculate planetary hours."
        case .solarEventUnavailable:
            "Sunrise or sunset could not be calculated for this date and location."
        case .invalidSolarInterval:
            "The sunrise and sunset interval was invalid."
        }
    }
}
