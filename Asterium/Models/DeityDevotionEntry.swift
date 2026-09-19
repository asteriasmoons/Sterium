//
//  DeityDevotionEntry.swift
//  Sterium
//

import Foundation
import SwiftData

struct DeityDevotionOffering: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var type: String
    var description: String
}

@Model
final class DeityDevotionEntry {
    var id: UUID = UUID()
    var title: String = ""
    var deity: String = ""
    var date: Date = Date()
    var devotionType: String = ""
    var intentions: String = ""
    var practicesPerformed: String = ""
    var sacredSpace: String = ""
    var offeringGiven: String = ""
    private var offeringsData: Data?
    var prayerOrInvocation: String = ""
    var reasonForConnection: String = ""
    var receivedMessage: Bool = false
    var messageTypes: String = ""
    var messagesReceived: String = ""
    var feelingsDuringPracticeSelections: String = ""
    var feelingsDuringPractice: String = ""
    var noticedSignsAfterwards: Bool = false
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

    var offerings: [DeityDevotionOffering] {
        get {
            if let offeringsData,
               let decoded = try? JSONDecoder().decode([DeityDevotionOffering].self, from: offeringsData) {
                return decoded
            }

            let legacyOffering = offeringGiven.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !legacyOffering.isEmpty else { return [] }
            return [DeityDevotionOffering(type: "Other", description: legacyOffering)]
        }
        set {
            offeringsData = try? JSONEncoder().encode(newValue)
            offeringGiven = newValue
                .map { [$0.type, $0.description].filter { !$0.isEmpty }.joined(separator: ": ") }
                .joined(separator: "\n")
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        deity: String,
        date: Date = .now,
        devotionType: String = "",
        intentions: String = "",
        practicesPerformed: String = "",
        sacredSpace: String = "",
        offeringGiven: String = "",
        offerings: [DeityDevotionOffering] = [],
        prayerOrInvocation: String = "",
        reasonForConnection: String = "",
        receivedMessage: Bool = false,
        messageTypes: String = "",
        messagesReceived: String = "",
        feelingsDuringPracticeSelections: String = "",
        feelingsDuringPractice: String = "",
        noticedSignsAfterwards: Bool = false,
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
        self.intentions = intentions
        self.practicesPerformed = practicesPerformed
        self.sacredSpace = sacredSpace
        self.offeringGiven = offeringGiven
        if offerings.isEmpty && !offeringGiven.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.offeringsData = nil
        } else {
            self.offeringsData = try? JSONEncoder().encode(offerings)
        }
        self.prayerOrInvocation = prayerOrInvocation
        self.reasonForConnection = reasonForConnection
        self.receivedMessage = receivedMessage
        self.messageTypes = messageTypes
        self.messagesReceived = messagesReceived
        self.feelingsDuringPracticeSelections = feelingsDuringPracticeSelections
        self.feelingsDuringPractice = feelingsDuringPractice
        self.noticedSignsAfterwards = noticedSignsAfterwards
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
