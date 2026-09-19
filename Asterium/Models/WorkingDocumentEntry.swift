//
//  WorkingDocumentEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class WorkingDocumentEntry {
    var id: UUID = UUID()
    var title: String = ""
    var dateTime: Date = Date()
    var intention: String = ""
    var categoryRawValue: String = WorkingCategory.other.rawValue
    var workingKindRawValue: String = WorkingKind.spell.rawValue
    var purpose: String = ""
    var ingredientsAndTools: String = ""
    var moonPhase: String = ""
    var zodiacSign: String = ""
    var planetaryDay: String = ""
    var deity: String?
    var location: String = ""
    var preparationNotes: String = ""
    var procedureSteps: String = ""
    var expectations: String = ""
    var notes: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.workingDocumentEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.workingDocumentEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    // Inverse for WorkingResultEntry.linkedWorking.
    // The relationship is optional underneath for CloudKit safety.
    @Relationship(deleteRule: .nullify, inverse: \WorkingResultEntry.linkedWorking)
    private var storedResults: [WorkingResultEntry]?

    var category: WorkingCategory {
        get { WorkingCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    var workingKind: WorkingKind {
        get { WorkingKind(rawValue: workingKindRawValue) ?? .spell }
        set { workingKindRawValue = newValue.rawValue }
    }

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.workingDocumentEntry !== self {
                attachment.workingDocumentEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.workingDocumentEntry !== self {
                relation.workingDocumentEntry = self
            }
        }
    }

    var results: [WorkingResultEntry] {
        get { storedResults ?? [] }
        set {
            storedResults = newValue
            for result in newValue where result.linkedWorking !== self {
                result.linkedWorking = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        dateTime: Date = .now,
        intention: String = "",
        category: WorkingCategory = .other,
        workingKind: WorkingKind = .spell,
        purpose: String = "",
        ingredientsAndTools: String = "",
        moonPhase: String = "",
        zodiacSign: String = "",
        planetaryDay: String = "",
        deity: String? = nil,
        location: String = "",
        preparationNotes: String = "",
        procedureSteps: String = "",
        expectations: String = "",
        notes: String = "",
        importance: Int = 1,
        tags: [String] = [],
        attachments: [GrimoireAttachment] = [],
        relatedEntries: [GrimoireRelatedEntry] = [],
        results: [WorkingResultEntry] = [],
        additionalNotes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.dateTime = dateTime
        self.intention = intention
        self.categoryRawValue = category.rawValue
        self.workingKindRawValue = workingKind.rawValue
        self.purpose = purpose
        self.ingredientsAndTools = ingredientsAndTools
        self.moonPhase = moonPhase
        self.zodiacSign = zodiacSign
        self.planetaryDay = planetaryDay
        self.deity = deity
        self.location = location
        self.preparationNotes = preparationNotes
        self.procedureSteps = procedureSteps
        self.expectations = expectations
        self.notes = notes
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries
        self.storedResults = results

        for attachment in attachments {
            attachment.workingDocumentEntry = self
        }

        for relation in relatedEntries {
            relation.workingDocumentEntry = self
        }

        for result in results {
            result.linkedWorking = self
        }
    }
}
