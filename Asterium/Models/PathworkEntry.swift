//
//  PathworkEntry.swift
//  Sterium
//

import Foundation
import SwiftData

struct PathworkStudySource: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var label: String
    var link: String
}

struct PathworkStudyResource: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var types: [String]
    var sources: [PathworkStudySource]
    var learned: [String]
}

private enum PathworkStudyResourceCoding {
    static let prefix = "asterium-pathwork-resources-v1:"

    static func decode(_ value: String) -> [PathworkStudyResource]? {
        guard value.hasPrefix(prefix),
              let data = Data(base64Encoded: String(value.dropFirst(prefix.count))) else { return nil }
        return try? JSONDecoder().decode([PathworkStudyResource].self, from: data)
    }

    static func encode(_ resources: [PathworkStudyResource]) -> String {
        guard let data = try? JSONEncoder().encode(resources) else { return "" }
        return prefix + data.base64EncodedString()
    }
}

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
    var nextStepsList: [String] = []

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

    var studyingResources: [PathworkStudyResource] {
        get {
            if let decoded = PathworkStudyResourceCoding.decode(resourcesStudying) {
                return decoded
            }
            let legacy = resourcesStudying.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !legacy.isEmpty else { return [] }
            return [PathworkStudyResource(name: legacy, types: [], sources: [], learned: [])]
        }
        set {
            resourcesStudying = PathworkStudyResourceCoding.encode(newValue)
        }
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
        nextStepsList: [String] = [],
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
        self.nextStepsList = nextStepsList
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
