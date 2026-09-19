//
//  ShadowWorkEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class ShadowWorkEntry {
    var id: UUID = UUID()
    var title: String = ""
    var prompt: String = ""
    var date: Date = Date()
    var trigger: String = ""
    var emotions: [String] = []
    var limitingBelief: String = ""
    var originsInfluences: [String] = []
    var whatThisRevealed: String = ""
    var newPerspective: String = ""
    var actionsToPractice: [String] = []
    var affirmation: String = ""
    var reflection: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.shadowWorkEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.shadowWorkEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.shadowWorkEntry !== self {
                attachment.shadowWorkEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.shadowWorkEntry !== self {
                relation.shadowWorkEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String = "",
        date: Date = .now,
        trigger: String = "",
        emotions: [String] = [],
        limitingBelief: String = "",
        originsInfluences: [String] = [],
        whatThisRevealed: String = "",
        newPerspective: String = "",
        actionsToPractice: [String] = [],
        affirmation: String = "",
        reflection: String = "",
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
        self.prompt = prompt
        self.date = date
        self.trigger = trigger
        self.emotions = emotions
        self.limitingBelief = limitingBelief
        self.originsInfluences = originsInfluences
        self.whatThisRevealed = whatThisRevealed
        self.newPerspective = newPerspective
        self.actionsToPractice = actionsToPractice
        self.affirmation = affirmation
        self.reflection = reflection
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.shadowWorkEntry = self
        }

        for relation in relatedEntries {
            relation.shadowWorkEntry = self
        }
    }
}
