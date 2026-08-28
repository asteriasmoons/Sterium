//
//  SpellEngineService.swift
//  Asterium
//

import Foundation

enum SpellCategory: String, CaseIterable, Codable, Identifiable {
    case protectionCleansing
    case loveRelationships
    case prosperitySuccess
    case personalGrowth
    case healingWellness
    case spiritualityDivination
    case wisdomMind
    case lifeChange

    var id: String { backendValue }

    var title: String {
        switch self {
        case .protectionCleansing: "Protection & Cleansing"
        case .loveRelationships: "Love & Relationships"
        case .prosperitySuccess: "Prosperity & Success"
        case .personalGrowth: "Personal Growth"
        case .healingWellness: "Healing & Wellness"
        case .spiritualityDivination: "Spirituality & Divination"
        case .wisdomMind: "Wisdom & Mind"
        case .lifeChange: "Life & Change"
        }
    }

    var backendValue: String {
        switch self {
        case .protectionCleansing: "protection_cleansing"
        case .loveRelationships: "love_relationships"
        case .prosperitySuccess: "prosperity_success"
        case .personalGrowth: "personal_growth"
        case .healingWellness: "healing_wellness"
        case .spiritualityDivination: "spirituality_divination"
        case .wisdomMind: "wisdom_mind"
        case .lifeChange: "life_change"
        }
    }

    var icon: String {
        switch self {
        case .protectionCleansing: "starshield"
        case .loveRelationships: "heartwavy"
        case .prosperitySuccess: "coinssparkle"
        case .personalGrowth: "levelup"
        case .healingWellness: "health"
        case .spiritualityDivination: "tarotcards"
        case .wisdomMind: "lovemind"
        case .lifeChange: "sparklearrowprogress"
        }
    }

    var intentions: [String] {
        switch self {
        case .protectionCleansing:
            ["Banishing", "Cleansing", "Protection", "Purification", "Grounding", "Release"]
        case .loveRelationships:
            ["Compassion", "Family", "Forgiveness", "Friendship", "Love", "Marriage", "Passion", "Reconciliation"]
        case .prosperitySuccess:
            ["Abundance", "Career", "Good Fortune", "Luck", "Opportunity", "Prosperity", "Success", "Wealth"]
        case .personalGrowth:
            ["Acceptance", "Ambition", "Confidence", "Courage", "Determination", "Growth", "Leadership", "Motivation", "Personal Power", "Resilience", "Self-Confidence", "Self-Discovery", "Self-Love", "Transformation"]
        case .healingWellness:
            ["Balance", "Emotional Healing", "Healing", "Happiness", "Harmony", "Hope", "Patience", "Peace", "Positivity", "Serenity", "Sleep", "Strength", "Vitality"]
        case .spiritualityDivination:
            ["Divination", "Dreams", "Intuition", "Manifestation", "Psychic Awareness", "Spiritual Growth"]
        case .wisdomMind:
            ["Clarity", "Communication", "Creativity", "Focus", "Inspiration", "Knowledge", "Memory", "Truth", "Wisdom"]
        case .lifeChange:
            ["Beginnings", "Boundaries", "Change", "Commitment", "Gratitude", "Home", "Travel"]
        }
    }
}

enum PractitionerLevel: String, CaseIterable, Codable, Identifiable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        }
    }
}

struct SpellIngredient: Codable, Equatable, Hashable {
    let name: String
    let purpose: String
}

struct SpellStep: Codable, Equatable, Hashable {
    let step: Int
    let instruction: String
}

struct SpellEntryResponse: Codable, Equatable, Identifiable {
    var id: String {
        "\(category)-\(intention)-\(level)-\(title)"
    }

    let category: String
    let categoryTitle: String
    let intention: String
    let level: String
    let context: String
    let title: String
    let focus: String
    let bestTiming: String
    let ingredients: [SpellIngredient]
    let tools: [String]
    let preparation: String
    let instructions: [SpellStep]
    let affirmation: String
    let visualization: String
    let closing: String
    let aftercare: String
    let duration: String
    let notes: String
    let cached: Bool
    let source: String
    let createdAt: String?
    let updatedAt: String?
}

private struct SpellGenerationRequest: Encodable {
    let category: String
    let intention: String
    let level: String
    let context: String
    let refresh: Bool?
}

private struct SpellListResponse: Decodable {
    let spells: [SpellEntryResponse]
}

enum SpellEngineServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The spell URL is invalid."
        case .invalidResponse:
            "The spell response was invalid."
        case .backend(let message):
            message
        }
    }
}

final class SpellEngineService {
    private struct BackendError: Decodable {
        let error: String
    }

    private static let savedPrefix = "asterium.savedSpells."

    private let baseURL: String
    private let session: URLSession
    private let userDefaults: UserDefaults

    init(
        baseURL: String = SpellEngineService.defaultBaseURL,
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.session = session
        self.userDefaults = userDefaults
    }

    func generate(
        category: SpellCategory,
        intention: String,
        level: PractitionerLevel,
        context: String,
        refresh: Bool = false
    ) async throws -> SpellEntryResponse {
        guard let url = URL(string: "\(baseURL)/api/spells/generate") else {
            throw SpellEngineServiceError.invalidURL
        }

        let requestBody = SpellGenerationRequest(
            category: category.backendValue,
            intention: intention,
            level: level.rawValue,
            context: context,
            refresh: refresh ? true : nil
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpellEngineServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(BackendError.self, from: data)
            throw SpellEngineServiceError.backend(
                backendError?.error ?? "Failed to generate spell."
            )
        }

        let spell = try JSONDecoder().decode(SpellEntryResponse.self, from: data)
        save(spell, category: category)
        return spell
    }

    func fetchSavedSpells(
        for category: SpellCategory
    ) async throws -> [SpellEntryResponse] {
        guard let url = URL(string: "\(baseURL)/api/spells/\(category.backendValue)") else {
            throw SpellEngineServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpellEngineServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(BackendError.self, from: data)
            throw SpellEngineServiceError.backend(
                backendError?.error ?? "Failed to fetch saved spells."
            )
        }

        let spells = try JSONDecoder().decode(SpellListResponse.self, from: data).spells
        save(spells, category: category)
        return spells
    }

    func savedSpells(for category: SpellCategory) -> [SpellEntryResponse] {
        guard let data = userDefaults.data(forKey: savedKey(for: category)),
              let spells = try? JSONDecoder().decode([SpellEntryResponse].self, from: data)
        else {
            return []
        }

        return spells.sorted {
            ($0.updatedAt ?? $0.createdAt ?? "") > ($1.updatedAt ?? $1.createdAt ?? "")
        }
    }

    func save(_ spell: SpellEntryResponse, category: SpellCategory) {
        var spells = savedSpells(for: category)
        spells.removeAll {
            $0.title.caseInsensitiveCompare(spell.title) == .orderedSame &&
                $0.intention.caseInsensitiveCompare(spell.intention) == .orderedSame
        }
        spells.insert(spell, at: 0)
        save(spells, category: category)
    }

    private func save(_ spells: [SpellEntryResponse], category: SpellCategory) {
        guard let data = try? JSONEncoder().encode(spells) else {
            return
        }

        userDefaults.set(data, forKey: savedKey(for: category))
    }

    private func savedKey(for category: SpellCategory) -> String {
        "\(Self.savedPrefix)\(category.backendValue)"
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
