//
//  MoonPhaseEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class MoonPhaseEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var moonPhase: String = ""
    var zodiacSign: String = ""
    var energyLevel: Int = 1
    var mood: String = ""
    var moodSelections: [String] = []
    var intentions: String = ""
    var ritualsPerformed: String = ""
    var manifestations: String = ""
    var intentionItems: [String] = []
    var ritualsPerformedItems: [String] = []
    var manifestationItems: [String] = []
    var reflections: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.moonPhaseEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.moonPhaseEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.moonPhaseEntry !== self {
                attachment.moonPhaseEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.moonPhaseEntry !== self {
                relation.moonPhaseEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        moonPhase: String = "",
        zodiacSign: String = "",
        energyLevel: Int = 1,
        mood: String = "",
        moodSelections: [String] = [],
        intentions: String = "",
        ritualsPerformed: String = "",
        manifestations: String = "",
        intentionItems: [String] = [],
        ritualsPerformedItems: [String] = [],
        manifestationItems: [String] = [],
        reflections: String = "",
        importance: Int = 1,
        tags: [String] = [],
        attachments: [GrimoireAttachment] = [],
        relatedEntries: [GrimoireRelatedEntry] = [],
        additionalNotes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.moonPhase = moonPhase
        self.zodiacSign = zodiacSign
        self.energyLevel = energyLevel
        self.mood = mood
        self.moodSelections = moodSelections
        self.intentions = intentions
        self.ritualsPerformed = ritualsPerformed
        self.manifestations = manifestations
        self.intentionItems = intentionItems
        self.ritualsPerformedItems = ritualsPerformedItems
        self.manifestationItems = manifestationItems
        self.reflections = reflections
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.moonPhaseEntry = self
        }

        for relation in relatedEntries {
            relation.moonPhaseEntry = self
        }
    }
}
