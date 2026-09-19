//
//  CorrespondenceEngineService.swift
//  Sterium
//

import Foundation
import SwiftData

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
    let foods: [String]?
    let drinks: [String]?
    let waysToCelebrate: [String]?
    let ritualIdeas: [String]?
    let activities: [String]?
    let decorations: [String]?
    let altarIdeas: [String]?
    let herbsAndPlants: [String]?
    let crystalsAndStones: [String]?
    let incenseAndScents: [String]?
    let seasonalThemes: [String]?
    let botanicalFamily: String?
    let partsUsed: [String]?
    let preparationMethods: [String]?
    let harvestingAndStorage: String?
    let commonSubstitutions: [String]?
    let complementaryHerbs: [String]?
    let smokeAndIncenseUses: [String]?
    let bloomingSeason: [String]?
    let preservationMethods: [String]?
    let floralSymbolism: [String]?
    let traditionalGiftMeanings: [String]?
    let complementaryFlowers: [String]?
    let mineralFamily: String?
    let composition: String?
    let hardness: String?
    let crystalSystem: String?
    let commonColorsAndVarieties: [String]?
    let cleansingMethods: [String]?
    let chargingMethods: [String]?
    let sourcePlant: String?
    let plantPartUsed: String?
    let aromaProfile: String?
    let blendingNotes: String?
    let complementaryOils: [String]?
    let shadesAndVariations: [String]?
    let candleMagicUses: [String]?
    let visualizationUses: [String]?
    let planetaryDay: String?
    let planetaryHour: String?
    let traditionalMetal: String?
    let associatedHerbs: [String]?
    let associatedCrystals: [String]?
    let magicalDomains: [String]?
    let modality: String?
    let polarity: String?
    let rulingPlanet: String?
    let houseAssociation: String?
    let symbolMeaning: String?
    let energeticQualities: [String]?
    let strengthsAndWeaknesses: [String]?
    let energeticTheme: String?
    let bestMagicalWork: [String]?
    let seasonalFoods: [String]?
    let seasonalDrinks: [String]?
    let seasonalPlants: [String]?
    let seasonalAnimals: [String]?
    let seasonalActivities: [String]?
    let magicalFocus: [String]?
    let associatedColors: [String]?
    let deityAssociations: [String]?
    let direction: String?
    let qualities: [String]?
    let associatedTools: [String]?
    let associatedSpirits: [String]?
    let associatedWeather: [String]?
    let invocationMethods: [String]?
    let altarRepresentation: String?
    let arcana: String?
    let suit: String?
    let numberOrRank: String?
    let element: String?
    let astrologicalAssociation: String?
    let uprightMeaning: String?
    let reversedMeaning: String?
    let keywords: [String]?
    let imageryAndSymbolism: String?
    let yesNoAssociation: String?
    let timingAssociation: String?
    let cultureTradition: String?
    let pantheon: String?
    let domains: [String]?
    let epithetsTitles: [String]?
    let sacredAnimals: [String]?
    let sacredPlants: [String]?
    let sacredPlaces: [String]?
    let offerings: [String]?
    let devotionalActs: [String]?
    let festivalsHolyDays: [String]?
    let mythsAndStories: String?
    let historicalWorship: String?
    let modernDevotionalPractices: [String]?
    let spiritType: String?
    let culturalContext: String?
    let domainsAssociations: [String]?
    let appearanceDescriptions: String?
    let signsAndPresence: [String]?
    let communicationMethods: [String]?
    let relatedSpirits: [String]?
    let protectiveConsiderations: String?
    let habitat: String?
    let behavioralTraits: [String]?
    let symbolicTraits: [String]?
    let omensAndSigns: [String]?
    let dreamMeaning: String?
    let encounterMeaning: String?
    let associatedSeasons: [String]?
    let spiritGuideInterpretations: String?
    let culturalSymbolism: String?
    let toolType: String?
    let traditionalPurpose: String?
    let howToUse: String?
    let preparation: String?
    let cleansing: String?
    let consecration: String?
    let charging: String?
    let storage: String?
    let materials: [String]?
    let commonVariations: [String]?
    let substitutions: [String]?
    let ritualApplications: [String]?
    let spellworkApplications: [String]?
    let coreMeaning: String?
    let positiveExpression: String?
    let shadowExpression: String?
    let repeatingNumberMeaning: String?
    let synchronicityMeaning: String?
    let manifestationAssociation: String?
    let divinationMeaning: String?
    let tarotConnections: [String]?
    let astrologicalConnections: [String]?
    let sacredGeometrySymbolism: String?
    let culturalHistoricalMeanings: [String]?
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

@MainActor
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
        refresh: Bool = false,
        modelContext: ModelContext
    ) async throws -> CorrespondenceEntryResponse {
        if let customEntry = customEntry(type: type, name: name, modelContext: modelContext) {
            return customEntry
        }

        guard let url = URL(string: "\(baseURL)/api/correspondences") else {
            throw CorrespondenceEngineServiceError.invalidURL
        }

        let requestBody = CorrespondenceEngineRequest(
            type: type.backendValue,
            name: name,
            refresh: (type == .sabbat || type == .herb || type == .flower || type == .crystal || type == .essentialOil || type == .color || type == .planet || type == .zodiacSign || type == .lunarPhase || type == .season || type == .dayOfWeek || type == .element || type == .tarotCard || type == .deity || type == .spirit || type == .animal || type == .tool || type == .number || refresh) ? true : nil
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
        save(entry, type: type, modelContext: modelContext)
        return entry
    }

    func savedEntries(for type: CorrespondenceType, modelContext: ModelContext) -> [CorrespondenceEntryResponse] {
        migrateLegacyEntriesIfNeeded(for: type, modelContext: modelContext)
        let typeValue = type.backendValue
        let descriptor = FetchDescriptor<SavedCorrespondenceRecord>(
            predicate: #Predicate { $0.type == typeValue }
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return records.compactMap { try? JSONDecoder().decode(CorrespondenceEntryResponse.self, from: $0.payload) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func save(_ entry: CorrespondenceEntryResponse, type: CorrespondenceType, modelContext: ModelContext) {
        migrateLegacyEntriesIfNeeded(for: type, modelContext: modelContext)
        let existingEntries = savedEntriesWithoutMigration(for: type, modelContext: modelContext)
        if let existingCustomEntry = existingEntries.first(where: {
            $0.entry.name.caseInsensitiveCompare(entry.name) == .orderedSame &&
            $0.entry.source.caseInsensitiveCompare("custom") == .orderedSame &&
            entry.source.caseInsensitiveCompare("custom") != .orderedSame
        }) {
            removeMatchingRecords(named: entry.name, type: type, keeping: existingCustomEntry.record, modelContext: modelContext)
            try? modelContext.save()
            return
        }
        removeMatchingRecords(named: entry.name, type: type, keeping: nil, modelContext: modelContext)
        insert(entry, type: type, modelContext: modelContext)
        try? modelContext.save()
    }

    func saveCustom(_ entry: CorrespondenceEntryResponse, type: CorrespondenceType, modelContext: ModelContext) {
        save(entry, type: type, modelContext: modelContext)
    }

    func delete(_ entry: CorrespondenceEntryResponse, type: CorrespondenceType, modelContext: ModelContext) {
        removeMatchingRecords(named: entry.name, type: type, keeping: nil, modelContext: modelContext)
        try? modelContext.save()
    }

    func customEntry(type: CorrespondenceType, name: String, modelContext: ModelContext) -> CorrespondenceEntryResponse? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else { return nil }
        return savedEntries(for: type, modelContext: modelContext).first {
            $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame &&
            $0.source.caseInsensitiveCompare("custom") == .orderedSame
        }
    }

    private func savedEntriesWithoutMigration(for type: CorrespondenceType, modelContext: ModelContext) -> [(record: SavedCorrespondenceRecord, entry: CorrespondenceEntryResponse)] {
        let typeValue = type.backendValue
        let descriptor = FetchDescriptor<SavedCorrespondenceRecord>(predicate: #Predicate { $0.type == typeValue })
        return ((try? modelContext.fetch(descriptor)) ?? []).compactMap { record in
            guard let entry = try? JSONDecoder().decode(CorrespondenceEntryResponse.self, from: record.payload) else { return nil }
            return (record, entry)
        }
    }

    private func insert(_ entry: CorrespondenceEntryResponse, type: CorrespondenceType, modelContext: ModelContext) {
        guard let payload = try? JSONEncoder().encode(entry) else { return }
        modelContext.insert(SavedCorrespondenceRecord(
            type: type.backendValue,
            name: entry.name,
            source: entry.source,
            updatedAt: entry.updatedAt ?? entry.createdAt ?? "",
            payload: payload
        ))
    }

    private func removeMatchingRecords(named name: String, type: CorrespondenceType, keeping recordToKeep: SavedCorrespondenceRecord?, modelContext: ModelContext) {
        for item in savedEntriesWithoutMigration(for: type, modelContext: modelContext) where item.entry.name.caseInsensitiveCompare(name) == .orderedSame {
            if item.record !== recordToKeep { modelContext.delete(item.record) }
        }
    }

    private func migrateLegacyEntriesIfNeeded(for type: CorrespondenceType, modelContext: ModelContext) {
        let key = savedKey(for: type)
        guard let data = userDefaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([CorrespondenceEntryResponse].self, from: data) else { return }
        for entry in entries {
            let exists = savedEntriesWithoutMigration(for: type, modelContext: modelContext).contains {
                $0.entry.name.caseInsensitiveCompare(entry.name) == .orderedSame
            }
            if !exists { insert(entry, type: type, modelContext: modelContext) }
        }
        do {
            try modelContext.save()
            userDefaults.removeObject(forKey: key)
        } catch {
            // Keep the legacy copy until SwiftData successfully saves it.
        }
    }

    private func savedKey(for type: CorrespondenceType) -> String {
        "\(Self.savedPrefix)\(type.backendValue)"
    }

    nonisolated private static var defaultBaseURL: String {
        if let configuredURL = Bundle.main.object(
            forInfoDictionaryKey: "API_BASE_URL"
        ) as? String,
           configuredURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return configuredURL
        }

        return "https://appapi.voxiverse.ink"
    }
}
