
//
//  PathworkEntry.swift
//  Asterium
//

import Foundation
import SwiftData

@Model
final class PathworkEntry {
    var id: UUID = UUID()
    var chapterTitle: String = ""
    var started: Date = Date()
    var currentStatusRawValue: String = PathworkStatus.exploring.rawValue
    var focusArea: String = ""
    var whyThisPath: String = ""
    var currentPractices: String = ""
    var goals: String = ""
    var currentChallenges: String = ""
    var recentBreakthroughs: String = ""
    var resourcesStudying: String = ""
    var reflection: String = ""
    var nextSteps: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.pathworkEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.pathworkEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var currentStatus: PathworkStatus {
        get { PathworkStatus(rawValue: currentStatusRawValue) ?? .exploring }
        set { currentStatusRawValue = newValue.rawValue }
    }

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.pathworkEntry !== self {
                attachment.pathworkEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.pathworkEntry !== self {
                relation.pathworkEntry = self
            }
        }
    }

    init(
        id: UUID = UUID(),
        chapterTitle: String,
        started: Date = .now,
        currentStatus: PathworkStatus = .exploring,
        focusArea: String = "",
        whyThisPath: String = "",
        currentPractices: String = "",
        goals: String = "",
        currentChallenges: String = "",
        recentBreakthroughs: String = "",
        resourcesStudying: String = "",
        reflection: String = "",
        nextSteps: String = "",
        importance: Int = 1,
        tags: [String] = [],
        attachments: [GrimoireAttachment] = [],
        relatedEntries: [GrimoireRelatedEntry] = [],
        additionalNotes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.chapterTitle = chapterTitle
        self.started = started
        self.currentStatusRawValue = currentStatus.rawValue
        self.focusArea = focusArea
        self.whyThisPath = whyThisPath
        self.currentPractices = currentPractices
        self.goals = goals
        self.currentChallenges = currentChallenges
        self.recentBreakthroughs = recentBreakthroughs
        self.resourcesStudying = resourcesStudying
        self.reflection = reflection
        self.nextSteps = nextSteps
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.pathworkEntry = self
        }

        for relation in relatedEntries {
            relation.pathworkEntry = self
        }
    }
}
