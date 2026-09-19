//
//  ManifestationEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class ManifestationEntry {
    var id: UUID = UUID()
    var title: String = ""
    var dateStarted: Date = Date()
    var manifestationType: String = ""
    var customManifestationType: String = ""
    var manifestationMethods: [String] = []
    var customManifestationMethod: String = ""
    var timeframe: String = "No Deadline"
    var specificTimeframeDate: Date = Date()
    var desire: String = ""
    var whyItMatters: String = ""
    var intention: String = ""
    var intentionItems: [String] = []
    var visualization: String = ""
    var desiredRealityItems: [String] = []
    var inspiredActions: String = ""
    var inspiredActionItems: [String] = []
    var obstacles: String = ""
    var obstacleItems: [String] = []
    var evidenceOfProgress: String = ""
    var evidenceItems: [String] = []
    var manifestationStatusRawValue: String = ManifestationStatus.inProgress.rawValue
    var manifestedDate: Date = Date()
    var outcome: String = ""
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
        manifestationType: String = "",
        customManifestationType: String = "",
        manifestationMethods: [String] = [],
        customManifestationMethod: String = "",
        timeframe: String = "No Deadline",
        specificTimeframeDate: Date = .now,
        desire: String = "",
        whyItMatters: String = "",
        intention: String = "",
        intentionItems: [String] = [],
        visualization: String = "",
        desiredRealityItems: [String] = [],
        inspiredActions: String = "",
        inspiredActionItems: [String] = [],
        obstacles: String = "",
        obstacleItems: [String] = [],
        evidenceOfProgress: String = "",
        evidenceItems: [String] = [],
        manifestationStatus: ManifestationStatus = .inProgress,
        manifestedDate: Date = .now,
        outcome: String = "",
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
        self.manifestationType = manifestationType
        self.customManifestationType = customManifestationType
        self.manifestationMethods = manifestationMethods
        self.customManifestationMethod = customManifestationMethod
        self.timeframe = timeframe
        self.specificTimeframeDate = specificTimeframeDate
        self.desire = desire
        self.whyItMatters = whyItMatters
        self.intention = intention
        self.intentionItems = intentionItems
        self.visualization = visualization
        self.desiredRealityItems = desiredRealityItems
        self.inspiredActions = inspiredActions
        self.inspiredActionItems = inspiredActionItems
        self.obstacles = obstacles
        self.obstacleItems = obstacleItems
        self.evidenceOfProgress = evidenceOfProgress
        self.evidenceItems = evidenceItems
        self.manifestationStatusRawValue = manifestationStatus.rawValue
        self.manifestedDate = manifestedDate
        self.outcome = outcome
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
