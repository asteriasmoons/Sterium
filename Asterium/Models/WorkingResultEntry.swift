
//
//  WorkingResultEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class WorkingResultEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var timeSinceWorking: String = ""
    var overallOutcomeRawValue: String = WorkingOutcome.unsure.rawValue
    var observableResults: String = ""
    var unexpectedOutcomes: String = ""
    var signsAndOmens: String = ""
    var lessonsLearned: String = ""
    var wouldRepeatRawValue: String = RepeatDecision.maybe.rawValue
    var changesNextTime: String = ""
    var notes: String = ""

    // CloudKit-safe optional to-one relationship.
    var linkedWorking: WorkingDocumentEntry?

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.workingResultEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.workingResultEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var overallOutcome: WorkingOutcome {
        get { WorkingOutcome(rawValue: overallOutcomeRawValue) ?? .unsure }
        set { overallOutcomeRawValue = newValue.rawValue }
    }

    var wouldRepeat: RepeatDecision {
        get { RepeatDecision(rawValue: wouldRepeatRawValue) ?? .maybe }
        set { wouldRepeatRawValue = newValue.rawValue }
    }

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.workingResultEntry !== self {
                attachment.workingResultEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.workingResultEntry !== self {
                relation.workingResultEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        linkedWorking: WorkingDocumentEntry? = nil,
        date: Date = .now,
        timeSinceWorking: String = "",
        overallOutcome: WorkingOutcome = .unsure,
        observableResults: String = "",
        unexpectedOutcomes: String = "",
        signsAndOmens: String = "",
        lessonsLearned: String = "",
        wouldRepeat: RepeatDecision = .maybe,
        changesNextTime: String = "",
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
        self.linkedWorking = linkedWorking
        self.date = date
        self.timeSinceWorking = timeSinceWorking
        self.overallOutcomeRawValue = overallOutcome.rawValue
        self.observableResults = observableResults
        self.unexpectedOutcomes = unexpectedOutcomes
        self.signsAndOmens = signsAndOmens
        self.lessonsLearned = lessonsLearned
        self.wouldRepeatRawValue = wouldRepeat.rawValue
        self.changesNextTime = changesNextTime
        self.notes = notes
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.workingResultEntry = self
        }

        for relation in relatedEntries {
            relation.workingResultEntry = self
        }
    }
}
