//
//  CurrentCorrespondencesService.swift
//  Sterium
//

import Foundation

struct CurrentCorrespondencesAIRequest: Encodable {
    let date: String
    let weekday: String
    let planetaryDay: String
    let planetaryHour: String?
    let nextPlanetaryHour: String?
    let moonPhase: String
    let moonSign: String
    let moonIlluminationPercent: Double
    let upcomingSabbat: String
    let daysUntilSabbat: Int
}

struct CurrentCorrespondencesAIResponse: Codable, Equatable {
    let title: String
    let message: String
    let planet: String
    let element: String
    let color: String
    let crystal: String
    let herb: String
    let keywords: [String]
}

enum CurrentCorrespondencesServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The current correspondences URL is invalid."
        case .invalidResponse:
            "The current correspondences response was invalid."
        case .backend(let message):
            message
        }
    }
}

final class CurrentCorrespondencesService {
    private struct CachedResponse: Codable {
        let dayKey: String
        let response: CurrentCorrespondencesAIResponse
    }

    private static let cacheKey = "currentCorrespondences.dailyCache"

    private let baseURL: String
    private let session: URLSession
    private let userDefaults: UserDefaults

    init(
        baseURL: String = CurrentCorrespondencesService.defaultBaseURL,
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.session = session
        self.userDefaults = userDefaults
    }

    func cachedResponse(
        for dayKey: String,
        planetaryDay: String
    ) -> CurrentCorrespondencesAIResponse? {
        guard let cached = cachedResponse(),
              cached.dayKey == dayKey,
              cached.response.planet.normalizedCorrespondenceValue ==
                planetaryDay.normalizedCorrespondenceValue
        else {
            return nil
        }

        return cached.response
    }

    func responseForToday(
        dayKey: String,
        requestBody: CurrentCorrespondencesAIRequest
    ) async throws -> CurrentCorrespondencesAIResponse {
        if let cached = cachedResponse(
            for: dayKey,
            planetaryDay: requestBody.planetaryDay
        ) {
            return cached
        }

        let response = try await fetch(requestBody)
        guard response.planet.normalizedCorrespondenceValue ==
                requestBody.planetaryDay.normalizedCorrespondenceValue
        else {
            throw CurrentCorrespondencesServiceError.backend(
                "Current correspondences returned \(response.planet) for \(requestBody.planetaryDay)."
            )
        }

        cache(response, dayKey: dayKey)
        return response
    }

    func fetch(
        _ requestBody: CurrentCorrespondencesAIRequest
    ) async throws -> CurrentCorrespondencesAIResponse {
        guard let url = URL(
            string: "\(baseURL)/api/spiritual/current-correspondences"
        ) else {
            throw CurrentCorrespondencesServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CurrentCorrespondencesServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let backendError = try? JSONDecoder().decode(
                CurrentCorrespondencesBackendError.self,
                from: data
            )

            throw CurrentCorrespondencesServiceError.backend(
                backendError?.error ?? "Failed to fetch current correspondences."
            )
        }

        return try JSONDecoder().decode(
            CurrentCorrespondencesAIResponse.self,
            from: data
        )
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

    private func cachedResponse() -> CachedResponse? {
        guard let data = userDefaults.data(forKey: Self.cacheKey) else {
            return nil
        }

        return try? JSONDecoder().decode(CachedResponse.self, from: data)
    }

    private func cache(
        _ response: CurrentCorrespondencesAIResponse,
        dayKey: String
    ) {
        let cachedResponse = CachedResponse(dayKey: dayKey, response: response)
        guard let data = try? JSONEncoder().encode(cachedResponse) else {
            return
        }

        userDefaults.set(data, forKey: Self.cacheKey)
    }
}

private struct CurrentCorrespondencesBackendError: Decodable {
    let error: String
}

private extension String {
    var normalizedCorrespondenceValue: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
