//
//  GrimoireSharedModels.swift
//  Sterium
//

import Foundation
import SwiftData

enum GrimoireEntryType: String, Codable, CaseIterable {
    case journal
    case workingDocument
    case workingResult
    case dream
    case synchronicity
    case pathwork
    case moonPhase
    case deityDevotion
    case divination
    case meditation
    case shadowWork
    case manifestation
    case experience
}

enum WorkingCategory: String, Codable, CaseIterable {
    case protection
    case prosperity
    case love
    case healing
    case banishing
    case cleansing
    case divination
    case other
}

enum WorkingKind: String, Codable, CaseIterable {
    case spell
    case ritual
}

enum WorkingOutcome: String, Codable, CaseIterable {
    case successful
    case partial
    case none
    case unsure
}

enum RepeatDecision: String, Codable, CaseIterable {
    case yes
    case no
    case maybe
}

enum DreamType: String, Codable, CaseIterable {
    case lucid
    case nightmare
    case recurring
    case symbolic
    case prophetic
    case ordinary
    case unsure
}

enum SleepQuality: String, Codable, CaseIterable {
    case veryPoor
    case poor
    case fair
    case good
    case excellent
}

enum PathworkStatus: String, Codable, CaseIterable {
    case exploring
    case active
    case paused
    case integrating
    case completed
}

enum ManifestationStatus: String, Codable, CaseIterable {
    case started
    case inProgress
    case earlyStages
    case manifested
    case notManifested
    case released
}

@Model
final class GrimoireAttachment {
    var id: UUID = UUID()
    var displayName: String = ""
    var relativePath: String = ""
    var kind: String = ""
    var createdAt: Date = Date()

    // CloudKit-safe optional inverse relationships.
    var journalEntry: JournalEntry?
    var workingDocumentEntry: WorkingDocumentEntry?
    var workingResultEntry: WorkingResultEntry?
    var dreamEntry: DreamEntry?
    var synchronicityEntry: SynchronicityEntry?
    var pathworkEntry: PathworkEntry?
    var moonPhaseEntry: MoonPhaseEntry?
    var deityDevotionEntry: DeityDevotionEntry?
    var divinationEntry: DivinationEntry?
    var meditationEntry: MeditationEntry?
    var shadowWorkEntry: ShadowWorkEntry?
    var manifestationEntry: ManifestationEntry?
    var experienceEntry: ExperienceEntry?

    init(
        id: UUID = UUID(),
        displayName: String,
        relativePath: String,
        kind: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.relativePath = relativePath
        self.kind = kind
        self.createdAt = createdAt
    }
}

@Model
final class GrimoireRelatedEntry {
    var id: UUID = UUID()
    var relatedEntryID: UUID = UUID()
    var relatedEntryTypeRawValue: String = GrimoireEntryType.journal.rawValue
    var relatedEntryTitle: String = ""
    var createdAt: Date = Date()

    // CloudKit-safe optional inverse relationships.
    var journalEntry: JournalEntry?
    var workingDocumentEntry: WorkingDocumentEntry?
    var workingResultEntry: WorkingResultEntry?
    var dreamEntry: DreamEntry?
    var synchronicityEntry: SynchronicityEntry?
    var pathworkEntry: PathworkEntry?
    var moonPhaseEntry: MoonPhaseEntry?
    var deityDevotionEntry: DeityDevotionEntry?
    var divinationEntry: DivinationEntry?
    var meditationEntry: MeditationEntry?
    var shadowWorkEntry: ShadowWorkEntry?
    var manifestationEntry: ManifestationEntry?
    var experienceEntry: ExperienceEntry?

    var relatedEntryType: GrimoireEntryType {
        get {
            GrimoireEntryType(rawValue: relatedEntryTypeRawValue) ?? .journal
        }
        set {
            relatedEntryTypeRawValue = newValue.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        relatedEntryID: UUID,
        relatedEntryType: GrimoireEntryType,
        relatedEntryTitle: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.relatedEntryID = relatedEntryID
        self.relatedEntryTypeRawValue = relatedEntryType.rawValue
        self.relatedEntryTitle = relatedEntryTitle
        self.createdAt = createdAt
    }
}
