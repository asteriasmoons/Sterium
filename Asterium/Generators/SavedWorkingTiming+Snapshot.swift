//
//  SavedWorkingTiming+Snapshot.swift
//  Sterium
//
//  App-only conversion between a generated WorkingTimingResult and its
//  persisted SavedWorkingTiming snapshot. This file references app-only types
//  (WorkingTimingResult) and therefore is NOT part of the SteriumShare target —
//  it lives in the app only, keeping the @Model itself dependency-free.
//
//  The snapshot is a lossless Codable round-trip: the ENTIRE result is encoded
//  to JSON and stored, and opening a saved timing decodes that JSON and shows
//  it exactly, without ever recalculating.
//

import Foundation
import CryptoKit

enum WorkingTimingSnapshotCoder {
    /// Deterministic encoder so the same result always produces identical bytes
    /// (required for a stable content hash used to de-duplicate saves).
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()

    static let decoder = JSONDecoder()
}

extension WorkingTimingResult {
    /// The entire result encoded as JSON (the stored snapshot).
    func encodedSnapshot() throws -> Data {
        try WorkingTimingSnapshotCoder.encoder.encode(self)
    }

    /// Stable SHA-256 hash of the canonical JSON encoding. Two generations that
    /// produce the same result hash identically, which is how a duplicate save
    /// is detected.
    func contentHash() -> String {
        guard let data = try? encodedSnapshot() else { return "" }
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

extension SavedWorkingTiming {
    /// Builds a persistable snapshot from a generated result, denormalizing the
    /// fields the Saved Timings list needs for display, sorting, and the
    /// Upcoming/Past split.
    static func make(from result: WorkingTimingResult) throws -> SavedWorkingTiming {
        let best = result.best.conditions

        let primary: String = {
            let candidates = [
                result.profile.primaryIntention,
                result.profile.interpretedIntention,
                result.userIntention
            ]
            for candidate in candidates {
                let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty == false { return trimmed }
            }
            return "Working Timing"
        }()

        return SavedWorkingTiming(
            createdAt: .now,
            primaryIntention: primary,
            bestStart: best.start,
            bestEnd: best.end,
            strengthLabel: result.best.strengthLabel,
            planetaryDayName: best.planetaryDay.displayName,
            planetaryHourName: best.planetaryHour?.displayName ?? "",
            contentHash: result.contentHash(),
            snapshotData: try result.encodedSnapshot()
        )
    }

    /// Decodes the stored snapshot back into a full result for display.
    /// Returns nil only if the stored data is unreadable.
    var decodedResult: WorkingTimingResult? {
        guard snapshotData.isEmpty == false else { return nil }
        return try? WorkingTimingSnapshotCoder.decoder.decode(WorkingTimingResult.self, from: snapshotData)
    }
}
