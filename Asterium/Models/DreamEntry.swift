
//
//  DreamEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class DreamEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var sleepQualityRawValue: String = SleepQuality.fair.rawValue
    var dreamTypeRawValue: String = DreamType.ordinary.rawValue
    var dreamSummary: String = ""
    var symbols: [String] = []
    var peoplePresent: [String] = []
    var animals: [String] = []
    var locations: [String] = []
    var dominantEmotions: [String] = []
    var colors: [String] = []
    var interpretation: String = ""
    var followUpActions: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.dreamEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.dreamEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var sleepQuality: SleepQuality {
        get { SleepQuality(rawValue: sleepQualityRawValue) ?? .fair }
        set { sleepQualityRawValue = newValue.rawValue }
    }

    var dreamType: DreamType {
        get { DreamType(rawValue: dreamTypeRawValue) ?? .ordinary }
        set { dreamTypeRawValue = newValue.rawValue }
    }

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.dreamEntry !== self {
                attachment.dreamEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.dreamEntry !== self {
                relation.dreamEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        sleepQuality: SleepQuality = .fair,
        dreamType: DreamType = .ordinary,
        dreamSummary: String = "",
        symbols: [String] = [],
        peoplePresent: [String] = [],
        animals: [String] = [],
        locations: [String] = [],
        dominantEmotions: [String] = [],
        colors: [String] = [],
        interpretation: String = "",
        followUpActions: String = "",
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
        self.sleepQualityRawValue = sleepQuality.rawValue
        self.dreamTypeRawValue = dreamType.rawValue
        self.dreamSummary = dreamSummary
        self.symbols = symbols
        self.peoplePresent = peoplePresent
        self.animals = animals
        self.locations = locations
        self.dominantEmotions = dominantEmotions
        self.colors = colors
        self.interpretation = interpretation
        self.followUpActions = followUpActions
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.dreamEntry = self
        }

        for relation in relatedEntries {
            relation.dreamEntry = self
        }
    }
}
