//
//  CorrespondenceEngineService.swift
//  Asterium
//

import Foundation

enum CorrespondenceType: String, CaseIterable, Codable, Identifiable {
    case herb
    case flower
    case crystal
    case essentialOil
    case color
    case planet
    case zodiacSign
    case lunarPhase
    case sabbat
    case season
    case dayOfWeek
    case element
    case tarotCard
    case deity
    case spirit
    case animal
    case tool
    case number

    var id: String { backendValue }

    var title: String {
        switch self {
        case .herb: "Herbs"
        case .flower: "Flowers"
        case .crystal: "Crystals"
        case .essentialOil: "Essential Oils"
        case .color: "Colors"
        case .planet: "Planets"
        case .zodiacSign: "Zodiac Signs"
        case .lunarPhase: "Lunar Phases"
        case .sabbat: "Sabbats"
        case .season: "Seasons"
        case .dayOfWeek: "Days of the Week"
        case .element: "Elements"
        case .tarotCard: "Tarot Cards"
        case .deity: "Deities"
        case .spirit: "Spirits"
        case .animal: "Animals"
        case .tool: "Tools"
        case .number: "Numbers"
        }
    }

    var singularTitle: String {
        switch self {
        case .herb: "Herb"
        case .flower: "Flower"
        case .crystal: "Crystal"
        case .essentialOil: "Essential Oil"
        case .color: "Color"
        case .planet: "Planet"
        case .zodiacSign: "Zodiac Sign"
        case .lunarPhase: "Lunar Phase"
        case .sabbat: "Sabbat"
        case .season: "Season"
        case .dayOfWeek: "Day"
        case .element: "Element"
        case .tarotCard: "Tarot Card"
        case .deity: "Deity"
        case .spirit: "Spirit"
        case .animal: "Animal"
        case .tool: "Tool"
        case .number: "Number"
        }
    }

    var backendValue: String {
        switch self {
        case .essentialOil: "essential_oil"
        case .zodiacSign: "zodiac_sign"
        case .lunarPhase: "lunar_phase"
        case .dayOfWeek: "day_of_week"
        case .tarotCard: "tarot_card"
        default: rawValue
        }
    }

    var icon: String {
        switch self {
        case .herb: "seedling"
        case .flower: "flower"
        case .crystal: "crystalball"
        case .essentialOil: "lovedropper"
        case .color: "paintdrop"
        case .planet: "planet"
        case .zodiacSign: "starchart"
        case .lunarPhase: "themoon"
        case .sabbat: "ringstarcal"
        case .season: "treeoutside"
        case .dayOfWeek: "dotscal"
        case .element: "sparklesstarflag"
        case .tarotCard: "tarotcards"
        case .deity: "starchalice"
        case .spirit: "ghost"
        case .animal: "paw"
        case .tool: "wand"
        case .number: "numcal"
        }
    }
}

struct CorrespondenceExplanation: Codable, Equatable, Hashable {
    let name: String
    let explanation: String
}

struct CorrespondenceNumerology: Codable, Equatable, Hashable {
    let number: String
    let significance: String
}

struct CorrespondenceTarotAssociation: Codable, Equatable, Hashable {
    let card: String
    let explanation: String
}

struct CorrespondenceLunarPhase: Codable, Equatable, Hashable {
    let phase: String
    let explanation: String
}

struct CorrespondenceSeason: Codable, Equatable, Hashable {
    let season: String
    let explanation: String
}

struct CorrespondenceDayOfWeek: Codable, Equatable, Hashable {
    let day: String
    let explanation: String
}

struct CorrespondenceColor: Codable, Equatable, Hashable {
    let color: String
    let meaning: String
}

struct CorrespondenceEntryResponse: Codable, Equatable, Identifiable {
    var id: String { "\(type)-\(name.lowercased())" }

    let type: String
    let name: String
    let intentions: [String]
    let purposes: [String]
    let alternativeNames: [String]
    let scientificName: String
    let shortDescription: String
    let planetaryCorrespondences: [String]
    let zodiacCorrespondences: [String]
    let elementalCorrespondences: [String]
    let deities: [String]
    let chakraAssociations: [CorrespondenceExplanation]
    let numerology: [CorrespondenceNumerology]
    let tarotAssociations: [CorrespondenceTarotAssociation]
    let sabbats: [String]
    let lunarPhases: [CorrespondenceLunarPhase]
    let seasons: [CorrespondenceSeason]
    let daysOfWeek: [CorrespondenceDayOfWeek]
    let colorCorrespondences: [CorrespondenceColor]
    let symbols: [String]
    let usesInSpellwork: [String]
    let usesInRitual: String
    let usage: String
    let divinationAssociations: String
    let spiritualMeanings: [String]
    let historicalNotes: String
    let folklore: String
    let warnings: String
    let cached: Bool
    let source: String
    let createdAt: String?
    let updatedAt: String?
}

struct CorrespondenceEngineRequest: Encodable {
    let type: String
    let name: String
    let refresh: Bool?
}

enum CorrespondenceEngineServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The correspondence URL is invalid."
        case .invalidResponse:
            "The correspondence response was invalid."
        case .backend(let message):
            message
        }
    }
}

final class CorrespondenceEngineService {
    private struct BackendError: Decodable {
        let error: String
    }

    private static let savedPrefix = "asterium.savedCorrespondences."

    private let baseURL: String
    private let session: URLSession
    private let userDefaults: UserDefaults

    init(
        baseURL: String = CorrespondenceEngineService.defaultBaseURL,
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.session = session
        self.userDefaults = userDefaults
    }

    func generate(
        type: CorrespondenceType,
        name: String,
        refresh: Bool = false
    ) async throws -> CorrespondenceEntryResponse {
        guard let url = URL(string: "\(baseURL)/api/correspondences") else {
            throw CorrespondenceEngineServiceError.invalidURL
        }

        let requestBody = CorrespondenceEngineRequest(
            type: type.backendValue,
            name: name,
            refresh: refresh ? true : nil
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CorrespondenceEngineServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(BackendError.self, from: data)
            throw CorrespondenceEngineServiceError.backend(
                backendError?.error ?? "Failed to generate correspondence."
            )
        }

        let entry = try JSONDecoder().decode(CorrespondenceEntryResponse.self, from: data)
        save(entry, type: type)
        return entry
    }

    func savedEntries(for type: CorrespondenceType) -> [CorrespondenceEntryResponse] {
        guard let data = userDefaults.data(forKey: savedKey(for: type)),
              let entries = try? JSONDecoder().decode(
                [CorrespondenceEntryResponse].self,
                from: data
              )
        else {
            return []
        }

        return entries.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func save(_ entry: CorrespondenceEntryResponse, type: CorrespondenceType) {
        var entries = savedEntries(for: type)
        entries.removeAll {
            $0.name.caseInsensitiveCompare(entry.name) == .orderedSame
        }
        entries.append(entry)

        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }

        userDefaults.set(data, forKey: savedKey(for: type))
    }

    private func savedKey(for type: CorrespondenceType) -> String {
        "\(Self.savedPrefix)\(type.backendValue)"
    }

    private static var defaultBaseURL: String {
        if let configuredURL = Bundle.main.object(
            forInfoDictionaryKey: "API_BASE_URL"
        ) as? String,
           configuredURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return configuredURL
        }

        return "https://appapi.voxiverse.ink"
    }
}
