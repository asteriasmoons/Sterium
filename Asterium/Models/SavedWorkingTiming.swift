//
//  SavedWorkingTiming.swift
//  Sterium
//
//  Persistent snapshot of a generated Working Timing result. Stored in the
//  unified CloudKit-backed shared store, so this model stays free of any
//  app-only types: it holds primitives for querying/sorting/de-duping plus a
//  single Codable JSON snapshot of the entire WorkingTimingResult. All the
//  conversion (encode/decode/hash) lives in an app-only extension so this file
//  also compiles cleanly inside the SteriumShare extension target.
//
//  Every property has a default and there are no unique constraints, matching
//  the other @Model types in the shared schema (a CloudKit requirement).
//

import Foundation
import SwiftData

@Model
final class SavedWorkingTiming {
    var id: UUID = UUID()
    var createdAt: Date = Date()

    // Denormalized summary fields (list display, sorting, and Upcoming/Past split).
    var primaryIntention: String = ""
    var bestStart: Date = Date()
    var bestEnd: Date = Date()
    var strengthLabel: String = ""
    var planetaryDayName: String = ""
    var planetaryHourName: String = ""   // "" when no location-based hour

    // Stable hash of the encoded result, used to prevent duplicate saves.
    var contentHash: String = ""

    // The entire WorkingTimingResult, encoded as JSON. This is the snapshot:
    // opening a saved timing decodes this and displays it verbatim, never
    // recalculating anything.
    @Attribute(.externalStorage) var snapshotData: Data = Data()

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        primaryIntention: String = "",
        bestStart: Date = .now,
        bestEnd: Date = .now,
        strengthLabel: String = "",
        planetaryDayName: String = "",
        planetaryHourName: String = "",
        contentHash: String = "",
        snapshotData: Data = Data()
    ) {
        self.id = id
        self.createdAt = createdAt
        self.primaryIntention = primaryIntention
        self.bestStart = bestStart
        self.bestEnd = bestEnd
        self.strengthLabel = strengthLabel
        self.planetaryDayName = planetaryDayName
        self.planetaryHourName = planetaryHourName
        self.contentHash = contentHash
        self.snapshotData = snapshotData
    }
}
