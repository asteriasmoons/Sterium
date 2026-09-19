//
//  ExperienceEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class ExperienceEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var content: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.experienceEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.experienceEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.experienceEntry !== self {
                attachment.experienceEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.experienceEntry !== self {
                relation.experienceEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        content: String = "",
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
        self.content = content
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.experienceEntry = self
        }

        for relation in relatedEntries {
            relation.experienceEntry = self
        }
    }
}
