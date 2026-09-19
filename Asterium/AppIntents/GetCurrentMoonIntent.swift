//
//  GetCurrentMoonIntent.swift
//  Sterium
//
//  Thin App Intent bridging the existing Current Moon dashboard data
//  (MoonPhaseCalculator) to Apple Shortcuts as structured output.
//  Uses TransientAppEntity so each @Property becomes a separately
//  selectable magic variable in Shortcuts.
//

import AppIntents
import CoreLocation
import Foundation

// MARK: - Transient entity

struct CurrentMoonEntity: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Current Moon")
    }

    @Property(title: "Phase")
    var phase: String

    @Property(title: "Zodiac")
    var zodiac: String

    @Property(title: "Illumination")
    var illumination: String

    @Property(title: "Illumination Percent")
    var illuminationPercent: Double

    @Property(title: "Moon Day")
    var moonDay: Int

    @Property(title: "Next Phase")
    var nextPhase: String

    @Property(title: "Days Until Next Phase")
    var daysUntilNextPhase: Int

    @Property(title: "Moonrise")
    var moonrise: String

    @Property(title: "Moonset")
    var moonset: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(phase) - \(zodiac)",
            subtitle: "\(illumination), Moon Day \(moonDay)"
        )
    }

    init() {
        self.phase = ""
        self.zodiac = ""
        self.illumination = ""
        self.illuminationPercent = 0
        self.moonDay = 0
        self.nextPhase = ""
        self.daysUntilNextPhase = 0
        self.moonrise = ""
        self.moonset = ""
    }

    init(from data: MoonPhaseData, moonrise: String = "", moonset: String = "") {
        self.phase = data.phaseName
        self.zodiac = data.signName
        let percent = Int(round(data.illuminationPercent))
        self.illumination = "\(percent)%"
        self.illuminationPercent = data.illuminationPercent
        self.moonDay = data.moonDay
        self.nextPhase = "\(data.daysUntilNextPhase)d"
        self.daysUntilNextPhase = data.daysUntilNextPhase
        self.moonrise = moonrise
        self.moonset = moonset
    }

    // Mirrors HomeView.moonRiseSetText so the dashboard and Shortcuts show
    // the same string for Moonrise and Moonset.
    static func riseSetText(_ date: Date?, hasCoordinate: Bool) -> String {
        guard hasCoordinate else { return "Location Needed" }
        guard let date else { return "None today" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Intent

struct GetCurrentMoonIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Moon"

    static var description = IntentDescription(
        "Returns the current moon phase, zodiac sign, illumination, moon day, and days until the next phase."
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<CurrentMoonEntity> {
        let now = Date()
        let data = MoonPhaseCalculator.calculate(for: now)

        // Reuse the existing MoonRiseSetCalculator + location provider so the
        // dashboard and Shortcuts always agree on Moonrise/Moonset.
        var coord: CLLocationCoordinate2D?
        do {
            coord = try await PlanetaryHourLocationProvider.currentCoordinate()
        } catch {
            coord = nil
        }

        var riseText = CurrentMoonEntity.riseSetText(nil, hasCoordinate: coord != nil)
        var setText = CurrentMoonEntity.riseSetText(nil, hasCoordinate: coord != nil)

        if let coord {
            let result = MoonRiseSetCalculator().result(
                for: now,
                coordinate: coord,
                timeZone: .autoupdatingCurrent
            )
            riseText = CurrentMoonEntity.riseSetText(result?.moonrise, hasCoordinate: true)
            setText = CurrentMoonEntity.riseSetText(result?.moonset, hasCoordinate: true)
        }

        return .result(value: CurrentMoonEntity(from: data, moonrise: riseText, moonset: setText))
    }
}
