//
//  GetCurrentCorrespondencesIntent.swift
//  Sterium
//
//  Thin App Intent bridging the existing Current Correspondences dashboard
//  data (DailySpiritualCalculator.correspondences) to Apple Shortcuts as
//  structured output. Uses TransientAppEntity so each @Property becomes a
//  separately selectable magic variable in Shortcuts. No AI, no interpretation.
//

import AppIntents
import Foundation

// MARK: - Transient entity

struct CurrentCorrespondencesEntity: TransientAppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Current Correspondences")
    }

    @Property(title: "Planet")
    var planet: String

    @Property(title: "Element")
    var element: String

    @Property(title: "Color")
    var color: String

    @Property(title: "Crystal")
    var crystal: String

    @Property(title: "Herb")
    var herb: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(planet)",
            subtitle: "\(element) - \(color) - \(crystal) - \(herb)"
        )
    }

    init() {
        self.planet = ""
        self.element = ""
        self.color = ""
        self.crystal = ""
        self.herb = ""
    }

    init(from correspondences: DailyCorrespondences) {
        self.planet = correspondences.planet.displayName
        self.element = correspondences.element
        self.color = correspondences.color
        self.crystal = correspondences.crystal
        self.herb = correspondences.herb
    }
}

// MARK: - Intent

struct GetCurrentCorrespondencesIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Correspondences"

    static var description = IntentDescription(
        "Returns today's planet, element, color, crystal, and herb correspondences."
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<CurrentCorrespondencesEntity> {
        let planet = DailySpiritualCalculator.planetaryDay(for: Date())
        let correspondences = DailySpiritualCalculator.correspondences(for: planet)
        return .result(value: CurrentCorrespondencesEntity(from: correspondences))
    }
}
