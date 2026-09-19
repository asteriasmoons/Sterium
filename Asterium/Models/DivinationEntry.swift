//
//  DivinationEntry.swift
//  Sterium
//

import Foundation
import SwiftData

struct DivinationSpreadItem: Codable, Hashable, Identifiable {
    let id: UUID
    var label: String
    var question: String

    init(id: UUID = UUID(), label: String, question: String) {
        self.id = id
        self.label = label
        self.question = question
    }
}

struct DivinationCardSymbolItem: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var meaning: String

    init(id: UUID = UUID(), name: String, meaning: String) {
        self.id = id
        self.name = name
        self.meaning = meaning
    }
}

@Model
final class DivinationEntry {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()
    var method: String = ""
    var questionAsked: String = ""
    var deckOrTool: String = ""
    var spread: String = ""
    var cardsOrSymbolsDrawn: String = ""
    var interpretation: String = ""
    var advice: String = ""
    var followUp: String = ""
    var accuracyReview: String = ""

    var spreadLabel: String = ""
    private var storedSpreadItemsData: Data?
    private var storedSpreadQuestionsData: Data?
    private var storedCardSymbolItemsData: Data?

    var importance: Int = 1
    var tags: [String] = []
    var additionalNotes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \GrimoireAttachment.divinationEntry)
    private var storedAttachments: [GrimoireAttachment]?

    @Relationship(deleteRule: .cascade, inverse: \GrimoireRelatedEntry.divinationEntry)
    private var storedRelatedEntries: [GrimoireRelatedEntry]?

    var attachments: [GrimoireAttachment] {
        get { storedAttachments ?? [] }
        set {
            storedAttachments = newValue
            for attachment in newValue where attachment.divinationEntry !== self {
                attachment.divinationEntry = self
            }
        }
    }

    var relatedEntries: [GrimoireRelatedEntry] {
        get { storedRelatedEntries ?? [] }
        set {
            storedRelatedEntries = newValue
            for relation in newValue where relation.divinationEntry !== self {
                relation.divinationEntry = self
            }
        }
    }

    var spreadItems: [DivinationSpreadItem] {
        get {
            if let storedSpreadItemsData,
               let decoded = try? JSONDecoder().decode([DivinationSpreadItem].self, from: storedSpreadItemsData) {
                return decoded
            }

            let legacySpread = spread.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !legacySpread.isEmpty else { return [] }
            return [DivinationSpreadItem(label: "Spread", question: legacySpread)]
        }
        set {
            storedSpreadItemsData = try? JSONEncoder().encode(newValue)
            spread = newValue
                .map { [$0.label, $0.question].filter { !$0.isEmpty }.joined(separator: ": ") }
                .joined(separator: "\n")
        }
    }

    var cardSymbolItems: [DivinationCardSymbolItem] {
        get {
            if let storedCardSymbolItemsData,
               let decoded = try? JSONDecoder().decode([DivinationCardSymbolItem].self, from: storedCardSymbolItemsData) {
                return decoded
            }

            let legacyCards = cardsOrSymbolsDrawn.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !legacyCards.isEmpty else { return [] }
            return [DivinationCardSymbolItem(name: "Cards / Symbols Drawn", meaning: legacyCards)]
        }
        set {
            storedCardSymbolItemsData = try? JSONEncoder().encode(newValue)
            cardsOrSymbolsDrawn = newValue
                .map { [$0.name, $0.meaning].filter { !$0.isEmpty }.joined(separator: ": ") }
                .joined(separator: "\n")
        }
    }

    var spreadQuestions: [String] {
        get {
            if let storedSpreadQuestionsData,
               let decoded = try? JSONDecoder().decode([String].self, from: storedSpreadQuestionsData) {
                return decoded
            }

            if let storedSpreadItemsData,
               let decoded = try? JSONDecoder().decode([DivinationSpreadItem].self, from: storedSpreadItemsData) {
                return decoded.map(\.question).filter { !$0.isEmpty }
            }

            let legacyLines = spread
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            guard !legacyLines.isEmpty else { return [] }
            return legacyLines.map { line in
                guard let separator = line.firstIndex(of: ":") else { return line }
                return String(line[line.index(after: separator)...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        set {
            storedSpreadQuestionsData = try? JSONEncoder().encode(newValue)
            spread = newValue
                .map { question in
                    let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !spreadLabel.isEmpty else { return trimmedQuestion }
                    return "\(spreadLabel): \(trimmedQuestion)"
                }
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

    init(
        id: UUID = UUID(),
        title: String,
        date: Date = .now,
        method: String = "",
        questionAsked: String = "",
        deckOrTool: String = "",
        spread: String = "",
        cardsOrSymbolsDrawn: String = "",
        interpretation: String = "",
        advice: String = "",
        followUp: String = "",
        accuracyReview: String = "",
        spreadLabel: String = "",
        spreadItems: [DivinationSpreadItem] = [],
        spreadQuestions: [String] = [],
        cardSymbolItems: [DivinationCardSymbolItem] = [],
        followUpItems: [String] = [],
        importance: Int = 1,
        tags: [String] = [],
        attachments: [GrimoireAttachment] = [],
        relatedEntries: [GrimoireRelatedEntry] = [],
        additionalNotes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        let resolvedSpreadLabel = spreadLabel.isEmpty ? spreadItems.first?.label ?? "" : spreadLabel

        self.id = id
        self.title = title
        self.date = date
        self.method = method
        self.questionAsked = questionAsked
        self.deckOrTool = deckOrTool
        self.spread = spread
        self.cardsOrSymbolsDrawn = cardsOrSymbolsDrawn
        self.interpretation = interpretation
        self.advice = advice
        self.followUp = followUpItems.isEmpty ? followUp : followUpItems.joined(separator: "\n")
        self.accuracyReview = accuracyReview
        self.spreadLabel = resolvedSpreadLabel
        self.spread = spreadQuestions.isEmpty
            ? spread
            : spreadQuestions.map { question in
                resolvedSpreadLabel.isEmpty ? question : "\(resolvedSpreadLabel): \(question)"
            }.joined(separator: "\n")
        self.storedSpreadItemsData = try? JSONEncoder().encode(spreadItems)
        self.storedSpreadQuestionsData = spreadQuestions.isEmpty ? nil : try? JSONEncoder().encode(spreadQuestions)
        self.storedCardSymbolItemsData = try? JSONEncoder().encode(cardSymbolItems)
        self.importance = importance
        self.tags = tags
        self.additionalNotes = additionalNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.storedAttachments = attachments
        self.storedRelatedEntries = relatedEntries

        for attachment in attachments {
            attachment.divinationEntry = self
        }

        for relation in relatedEntries {
            relation.divinationEntry = self
        }
    }
}
