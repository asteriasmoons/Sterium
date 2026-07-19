
//
//  DeityDevotionEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class DeityDevotionEntry {
    var id: UUID = UUID()
    var title: String = ""
    var deity: String = ""
    var date: Date = Date()
    var devotionType: String = ""
    var offeringGiven: String = ""
    var prayerOrInvocation: String = ""
    var reasonForConnection: String = ""
    var messagesReceived: String = ""
    var feelingsDuringPractice: String = ""
    var signsAfterwards: String = ""
    var reflection: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.deityDevotionEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.deityDevotionEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.deityDevotionEntry !== self {
                attachment.deityDevotionEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.deityDevotionEntry !== self {
                relation.deityDevotionEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        deity: String,
        date: Date = .now,
        devotionType: String = "",
        offeringGiven: String = "",
        prayerOrInvocation: String = "",
        reasonForConnection: String = "",
        messagesReceived: String = "",
        feelingsDuringPractice: String = "",
        signsAfterwards: String = "",
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
        self.deity = deity
        self.date = date
        self.devotionType = devotionType
        self.offeringGiven = offeringGiven
        self.prayerOrInvocation = prayerOrInvocation
        self.reasonForConnection = reasonForConnection
        self.messagesReceived = messagesReceived
        self.feelingsDuringPractice = feelingsDuringPractice
        self.signsAfterwards = signsAfterwards
        self.reflection = reflection
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.deityDevotionEntry = self
        }

        for relation in relatedEntries {
            relation.deityDevotionEntry = self
        }
    }
}
