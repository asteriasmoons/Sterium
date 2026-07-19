
//
//  ManifestationEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class ManifestationEntry {
    var id: UUID = UUID()
    var title: String = ""
    var dateStarted: Date = Date()
    var desire: String = ""
    var whyItMatters: String = ""
    var intention: String = ""
    var visualization: String = ""
    var inspiredActions: String = ""
    var obstacles: String = ""
    var evidenceOfProgress: String = ""
    var manifestationStatusRawValue: String = ManifestationStatus.inProgress.rawValue
    var reflection: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.manifestationEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.manifestationEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var manifestationStatus: ManifestationStatus {
        get { ManifestationStatus(rawValue: manifestationStatusRawValue) ?? .inProgress }
        set { manifestationStatusRawValue = newValue.rawValue }
    }

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.manifestationEntry !== self {
                attachment.manifestationEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.manifestationEntry !== self {
                relation.manifestationEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        dateStarted: Date = .now,
        desire: String = "",
        whyItMatters: String = "",
        intention: String = "",
        visualization: String = "",
        inspiredActions: String = "",
        obstacles: String = "",
        evidenceOfProgress: String = "",
        manifestationStatus: ManifestationStatus = .inProgress,
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
        self.dateStarted = dateStarted
        self.desire = desire
        self.whyItMatters = whyItMatters
        self.intention = intention
        self.visualization = visualization
        self.inspiredActions = inspiredActions
        self.obstacles = obstacles
        self.evidenceOfProgress = evidenceOfProgress
        self.manifestationStatusRawValue = manifestationStatus.rawValue
        self.reflection = reflection
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.manifestationEntry = self
        }

        for relation in relatedEntries {
            relation.manifestationEntry = self
        }
    }
}
