//
//  MeditationEntry.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class MeditationEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var durationMinutes: Int = 0
    var technique: String = ""
    var customTechnique: String = ""
    var meditationKind: String = ""
    var customKind: String = ""
    var intention: String = ""
    var environment: String = ""
    var environmentType: String = ""
    var beforeMeditation: String = ""
    var duringMeditation: String = ""
    var afterMeditation: String = ""
    var insights: String = ""
    var followUp: String = ""

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.meditationEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.meditationEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.meditationEntry !== self {
                attachment.meditationEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.meditationEntry !== self {
                relation.meditationEntry = self
            }
        }
    }

    var intentionItems: [String] {
        get {
            intention
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            intention = newValue
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
    }

    var followUpItems: [String] {
        get {
            followUp
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            followUp = newValue
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
    }

    var techniqueDisplay: String {
        displaySelection(technique, customValue: customTechnique)
    }

    var meditationKindDisplay: String {
        displaySelection(meditationKind, customValue: customKind)
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        durationMinutes: Int = 0,
        technique: String = "",
        customTechnique: String = "",
        meditationKind: String = "",
        customKind: String = "",
        intention: String = "",
        environment: String = "",
        environmentType: String = "",
        beforeMeditation: String = "",
        duringMeditation: String = "",
        afterMeditation: String = "",
        insights: String = "",
        followUp: String = "",
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
        self.durationMinutes = durationMinutes
        self.technique = technique
        self.customTechnique = customTechnique
        self.meditationKind = meditationKind
        self.customKind = customKind
        self.intention = intention
        self.environment = environment
        self.environmentType = environmentType
        self.beforeMeditation = beforeMeditation
        self.duringMeditation = duringMeditation
        self.afterMeditation = afterMeditation
        self.insights = insights
        self.followUp = followUp
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.meditationEntry = self
        }

        for relation in relatedEntries {
            relation.meditationEntry = self
        }
    }

    private func displaySelection(_ rawValue: String, customValue: String) -> String {
        rawValue
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { value in
                if value == "Custom", !customValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return customValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return value
            }
            .joined(separator: ", ")
    }
}
