
//
//  SynchronicityEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class SynchronicityEntry {
    var id: UUID = UUID()
    var title: String = ""
    var dateTime: Date = Date()
    var category: String = ""
    var whatHappened: String = ""
    var location: String = ""
    var emotionalState: String = ""
    var possibleMeaning: String = ""
    var relatedEvent: String = ""
    var confidence: Int = 1
    var notes: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.synchronicityEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.synchronicityEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.synchronicityEntry !== self {
                attachment.synchronicityEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.synchronicityEntry !== self {
                relation.synchronicityEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        dateTime: Date = .now,
        category: String = "",
        whatHappened: String = "",
        location: String = "",
        emotionalState: String = "",
        possibleMeaning: String = "",
        relatedEvent: String = "",
        confidence: Int = 1,
        notes: String = "",
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
        self.dateTime = dateTime
        self.category = category
        self.whatHappened = whatHappened
        self.location = location
        self.emotionalState = emotionalState
        self.possibleMeaning = possibleMeaning
        self.relatedEvent = relatedEvent
        self.confidence = confidence
        self.notes = notes
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.synchronicityEntry = self
        }

        for relation in relatedEntries {
            relation.synchronicityEntry = self
        }
    }
}
