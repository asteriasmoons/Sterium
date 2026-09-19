//
//  PlanetaryHourService.swift
//  Sterium
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class PlanetaryHourService: NSObject, ObservableObject {
    enum State: Equatable {
        case idle
        case requestingLocation
        case ready
        case locationDenied
        case unavailable(String)
    }

    @Published private(set) var result: PlanetaryHourResult?
    @Published private(set) var state: State = .idle
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let locationManager = CLLocationManager()
    private let calculator: PlanetaryHourCalculator
    private var timerCancellable: AnyCancellable?
    private var manualCoordinate: CLLocationCoordinate2D?

    init(calculator: PlanetaryHourCalculator = PlanetaryHourCalculator()) {
        self.calculator = calculator
        self.authorizationStatus = locationManager.authorizationStatus

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 5_000
        locationManager.pausesLocationUpdatesAutomatically = true

        let backgroundModes =
            Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes")
            as? [String] ?? []

        if backgroundModes.contains("location") {
            locationManager.allowsBackgroundLocationUpdates = true
        }

        startClock()
        begin()
    }

    deinit {
        timerCancellable?.cancel()
        locationManager.stopUpdatingLocation()
    }

    func begin() {
        authorizationStatus = locationManager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            state = .requestingLocation
            locationManager.requestAlwaysAuthorization()

        case .authorizedAlways:
            state = .requestingLocation
            refreshFromCachedLocationIfAvailable()
            locationManager.requestLocation()

        case .authorizedWhenInUse:
            state = .requestingLocation
            refreshFromCachedLocationIfAvailable()
            locationManager.requestAlwaysAuthorization()
            locationManager.requestLocation()

        case .denied, .restricted:
            if manualCoordinate == nil {
                state = .locationDenied
                result = nil
            } else {
                refresh()
            }

        @unknown default:
            state = .unavailable("Location authorization is unavailable.")
            result = nil
        }
    }

    func setManualLocation(
        latitude: Double,
        longitude: Double
    ) {
        let newCoordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        guard CLLocationCoordinate2DIsValid(newCoordinate) else {
            state = .unavailable("The manual location is invalid.")
            return
        }

        manualCoordinate = newCoordinate
        coordinate = newCoordinate
        refresh()
    }

    func clearManualLocation() {
        manualCoordinate = nil
        coordinate = nil
        begin()
    }

    func refresh(at date: Date = Date()) {
        guard let activeCoordinate = manualCoordinate ?? coordinate else {
            result = nil

            if authorizationStatus == .denied ||
                authorizationStatus == .restricted {
                state = .locationDenied
            } else {
                state = .requestingLocation
            }

            return
        }

        do {
            result = try calculator.result(
                at: date,
                coordinate: activeCoordinate,
                timeZone: .autoupdatingCurrent
            )
            state = .ready
        } catch {
            result = nil
            state = .unavailable(error.localizedDescription)
        }
    }

    private func startClock() {
        timerCancellable = Timer
            .publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.refresh(at: date)
            }
    }

    private func refreshFromCachedLocationIfAvailable() {
        guard manualCoordinate == nil,
              let cachedLocation = locationManager.location
        else {
            return
        }

        coordinate = cachedLocation.coordinate
        refresh()
    }
}

extension PlanetaryHourService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        let status = manager.authorizationStatus

        Task { @MainActor [weak self] in
            guard let self else { return }

            authorizationStatus = status

            switch status {
            case .authorizedAlways:
                state = .requestingLocation
                refreshFromCachedLocationIfAvailable()
                locationManager.requestLocation()

            case .authorizedWhenInUse:
                state = .requestingLocation
                refreshFromCachedLocationIfAvailable()
                locationManager.requestAlwaysAuthorization()
                locationManager.requestLocation()

            case .denied, .restricted:
                if manualCoordinate == nil {
                    state = .locationDenied
                    result = nil
                } else {
                    refresh()
                }

            case .notDetermined:
                state = .requestingLocation

            @unknown default:
                state = .unavailable(
                    "Location authorization is unavailable."
                )
                result = nil
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            coordinate = location.coordinate
            refresh()
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            if manualCoordinate != nil {
                refresh()
                return
            }

            if let cachedLocation = locationManager.location {
                coordinate = cachedLocation.coordinate
                refresh()
                return
            }

            state = .unavailable(error.localizedDescription)
            result = nil
        }
    }
}
