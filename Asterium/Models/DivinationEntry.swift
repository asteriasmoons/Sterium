
//
//  DivinationEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class DivinationEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var method: String = ""
    var questionAsked: String = ""
    var deckOrTool: String = ""
    var spread: String = ""
    var cardsOrSymbolsDrawn: String = ""
    var interpretation: String = ""
    var advice: String = ""
    var followUp: String = ""
    var accuracyReview: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.divinationEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.divinationEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.divinationEntry !== self {
                attachment.divinationEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.divinationEntry !== self {
                relation.divinationEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        method: String = "",
        questionAsked: String = "",
        deckOrTool: String = "",
        spread: String = "",
        cardsOrSymbolsDrawn: String = "",
        interpretation: String = "",
        advice: String = "",
        followUp: String = "",
        accuracyReview: String = "",
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
        self.method = method
        self.questionAsked = questionAsked
        self.deckOrTool = deckOrTool
        self.spread = spread
        self.cardsOrSymbolsDrawn = cardsOrSymbolsDrawn
        self.interpretation = interpretation
        self.advice = advice
        self.followUp = followUp
        self.accuracyReview = accuracyReview
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.divinationEntry = self
        }

        for relation in relatedEntries {
            relation.divinationEntry = self
        }
    }
}
