//
//  GetPlanetaryDayHourIntent.swift
//  Sterium
//
//  Thin App Intent bridging the existing Planetary Day & Hour dashboard data
//  (DailySpiritualCalculator + PlanetaryHourCalculator) to Apple Shortcuts as
//  structured output. Reuses the exact same calculator the dashboard uses.
//  Uses TransientAppEntity so each @Property becomes a separately selectable
//  magic variable in Shortcuts.
//

import AppIntents
import CoreLocation
import Foundation

// MARK: - Transient entity

struct PlanetaryDayHourEntity: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Planetary Day & Hour")
    }

    @Property(title: "Day")
    var day: String

    @Property(title: "Planet of the Day")
    var planetOfTheDay: String

    @Property(title: "Current Planetary Hour")
    var currentPlanetaryHour: String

    @Property(title: "Next Planetary Hour")
    var nextPlanetaryHour: String

    @Property(title: "Current Hour Start")
    var currentHourStart: Date

    @Property(title: "Current Hour End")
    var currentHourEnd: Date

    @Property(title: "Time Until Next Hour")
    var timeUntilNextHour: String // mirrors the dashboard string "N minutes" from HomeView.planetaryHourContent

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(day) - \(planetOfTheDay)",
            subtitle: "Hour: \(currentPlanetaryHour) -> \(nextPlanetaryHour)"
        )
    }

    init() {
        self.day = ""
        self.planetOfTheDay = ""
        self.currentPlanetaryHour = ""
        self.nextPlanetaryHour = ""
        self.currentHourStart = Date()
        self.currentHourEnd = Date()
        self.timeUntilNextHour = ""
    }

    init(day: String, planetOfTheDay: Planet, result: PlanetaryHourResult, now: Date) {
        self.day = day
        self.planetOfTheDay = planetOfTheDay.displayName
        self.currentPlanetaryHour = result.currentPlanet.displayName
        self.nextPlanetaryHour = result.nextPlanet.displayName
        self.currentHourStart = result.startTime
        self.currentHourEnd = result.endTime
        // Same minutesUntil() formula used by HomeView.planetaryHourContent for
        // its "Next: [Planet] in [N] minutes" line, so Shortcuts and the
        // dashboard always agree.
        let minutes = max(Int(ceil(result.nextChangeTime.timeIntervalSince(now) / 60)), 0)
        self.timeUntilNextHour = "\(minutes) minutes"
    }
}

// MARK: - Location provider

/// Bridges CLLocationManager (delegate-based) to async/await for App Intents,
/// so the intent can obtain the same one-shot coordinate the dashboard's
/// PlanetaryHourService uses to feed PlanetaryHourCalculator.
final class PlanetaryHourLocationProvider: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    static func currentCoordinate() async throws -> CLLocationCoordinate2D {
        let provider = PlanetaryHourLocationProvider()
        return try await provider.request()
    }

    private func request() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyKilometer

            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if let cached = manager.location {
                    resume(with: .success(cached.coordinate))
                    return
                }
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                resume(with: .failure(PlanetaryHourError.locationUnavailable))
            @unknown default:
                resume(with: .failure(PlanetaryHourError.locationUnavailable))
            }
        }
    }

    private func resume(with result: Result<CLLocationCoordinate2D, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if let cached = manager.location {
                resume(with: .success(cached.coordinate))
            } else {
                manager.requestLocation()
            }
        case .denied, .restricted:
            resume(with: .failure(PlanetaryHourError.locationUnavailable))
        case .notDetermined:
            break
        @unknown default:
            resume(with: .failure(PlanetaryHourError.locationUnavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else {
            resume(with: .failure(PlanetaryHourError.locationUnavailable))
            return
        }
        resume(with: .success(coord))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resume(with: .failure(error))
    }
}

// MARK: - Intent

struct GetPlanetaryDayHourIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Planetary Day & Hour"

    static var description = IntentDescription(
        "Returns today's planetary day and current/next planetary hour information."
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<PlanetaryDayHourEntity> {
        let now = Date()
        let day = DailySpiritualCalculator.weekdayName(for: now)
        let planet = DailySpiritualCalculator.planetaryDay(for: now)
        let coord = try await PlanetaryHourLocationProvider.currentCoordinate()
        let result = try PlanetaryHourCalculator().result(
            at: now,
            coordinate: coord,
            timeZone: .autoupdatingCurrent
        )
        return .result(value: PlanetaryDayHourEntity(
            day: day,
            planetOfTheDay: planet,
            result: result,
            now: now
        ))
    }
}
