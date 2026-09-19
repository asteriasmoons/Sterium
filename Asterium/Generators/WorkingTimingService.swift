//
//  WorkingTimingService.swift
//  Sterium
//
//  Networking for the Working Timing Finder. The backend only interprets the
//  user's free-form intention into symbolic conditions; Sterium's local
//  calculators (see WorkingTimingFinder) decide the actual date/time.
//

import Foundation

struct WorkingTimingRequest: Encodable {
    let intention: String
}

struct TimingPlanetPair: Codable, Equatable, Hashable, Sendable {
    let first: String
    let second: String
}

struct WorkingTimingProfile: Codable, Equatable, Sendable {
    let interpretedIntention: String
    let primaryIntention: String
    let secondaryIntentions: [String]
    let planetaryRulers: [String]
    let favorableMoonPhases: [String]
    let favorableNumerologyNumbers: [Int]
    let favorableAspects: [String]
    let supportivePlanetPairs: [TimingPlanetPair]
    let challengingPlanetPairs: [TimingPlanetPair]
    let keywords: [String]

    // Resilient decode: required intention strings, arrays default to empty so
    // a minor omission never fails the whole response.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        interpretedIntention = try c.decode(String.self, forKey: .interpretedIntention)
        primaryIntention = try c.decode(String.self, forKey: .primaryIntention)
        secondaryIntentions = (try? c.decode([String].self, forKey: .secondaryIntentions)) ?? []
        planetaryRulers = (try? c.decode([String].self, forKey: .planetaryRulers)) ?? []
        favorableMoonPhases = (try? c.decode([String].self, forKey: .favorableMoonPhases)) ?? []
        favorableNumerologyNumbers = (try? c.decode([Int].self, forKey: .favorableNumerologyNumbers)) ?? []
        favorableAspects = (try? c.decode([String].self, forKey: .favorableAspects)) ?? []
        supportivePlanetPairs = (try? c.decode([TimingPlanetPair].self, forKey: .supportivePlanetPairs)) ?? []
        challengingPlanetPairs = (try? c.decode([TimingPlanetPair].self, forKey: .challengingPlanetPairs)) ?? []
        keywords = (try? c.decode([String].self, forKey: .keywords)) ?? []
    }
}

enum WorkingTimingServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The working timing URL is invalid."
        case .invalidResponse: "The working timing response was invalid."
        case .backend(let message): message
        }
    }
}

final class WorkingTimingService {
    private let baseURL: String
    private let session: URLSession

    init(
        baseURL: String = WorkingTimingService.defaultBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.session = session
    }

    func fetch(intention: String) async throws -> WorkingTimingProfile {
        guard let url = URL(string: "\(baseURL)/api/spiritual/working-timing") else {
            throw WorkingTimingServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(WorkingTimingRequest(intention: intention))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WorkingTimingServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(WorkingTimingBackendError.self, from: data)
            throw WorkingTimingServiceError.backend(
                backendError?.error ?? "The working timing service returned an error."
            )
        }

        do {
            return try JSONDecoder().decode(WorkingTimingProfile.self, from: data)
        } catch {
            throw WorkingTimingServiceError.invalidResponse
        }
    }

    private static var defaultBaseURL: String {
        if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           configuredURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return configuredURL
        }
        return "https://appapi.voxiverse.ink"
    }
}

private struct WorkingTimingBackendError: Decodable {
    let error: String
}
