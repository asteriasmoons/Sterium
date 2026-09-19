//
//  SteriumShared.swift
//  Sterium
//
//  Single source of truth for Sterium's SwiftData persistence.
//
//  The entire app schema lives in ONE App Group-backed store so that both the
//  main Sterium app and the SteriumShare extension read and write the exact
//  same physical database (App Group: group.com.asteriasmoons.Sterium,
//  default.store). The main app opens it with CloudKit explicitly pinned to
//  iCloud.im.lystaria.Asterium; the extension opens the same file locally with
//  CloudKit disabled. This prevents Sterium's SwiftData store from ever using
//  the separate Voxiverse reporting container.
//
//  This mirrors the architecture already proven in Lurelia
//  (LureliaWidgetShared) so Sterium behaves identically: one local App Group
//  store -> one CloudKit container.
//

import Foundation
import SwiftData
import SQLite3

enum SteriumShared {
    static let appGroupID = "group.com.asteriasmoons.Sterium"
    static let sharedStoreFileName = "default.store"
    private static let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    // MARK: - Schema

    /// The complete Sterium SwiftData schema. Both targets compile every model
    /// referenced here, so both can open the shared store.
    static var sharedSchema: Schema {
        Schema([
            GrimoireAttachment.self,
            GrimoireRelatedEntry.self,
            JournalEntry.self,
            ExperienceEntry.self,
            WorkingDocumentEntry.self,
            WorkingResultEntry.self,
            DreamEntry.self,
            SynchronicityEntry.self,
            PathworkEntry.self,
            MoonPhaseEntry.self,
            DeityDevotionEntry.self,
            DivinationEntry.self,
            MeditationEntry.self,
            ShadowWorkEntry.self,
            ManifestationEntry.self,
            CustomGrimoireTemplate.self,
            CustomGrimoireTemplateVersion.self,
            CustomGrimoireEntry.self,
            SavedCorrespondenceRecord.self,
            SavedSpellRecord.self,
            GrimoireCustomFilter.self,
            VisionBoard.self,
            VisionBoardFolder.self,
            VisionBoardImage.self,
            SteriumEvent.self,
            HomeWidgetLayout.self,
            SubmittedReport.self,
            SubmittedReportAttachment.self,
            SavedWorkingTiming.self,
        ])
    }

    // MARK: - App Group locations

    static var appGroupContainerURL: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            fatalError("Could not access App Group container: \(appGroupID)")
        }
        return url
    }

    static var sharedStoreURL: URL {
        appGroupContainerURL.appendingPathComponent(sharedStoreFileName)
    }

    // MARK: - Container

    /// Opens the single shared store using the caller's explicit CloudKit mode.
    /// Main Sterium uses .private("iCloud.im.lystaria.Asterium"); SteriumShare uses .none.
    static func makeModelContainer(
        cloudKitDatabase: ModelConfiguration.CloudKitDatabase
    ) throws -> ModelContainer {
        let schema = sharedSchema
        let configuration = ModelConfiguration(
            "SteriumShared",
            schema: schema,
            url: sharedStoreURL,
            cloudKitDatabase: cloudKitDatabase
        )

        // Attempt 1: open the store as-is.
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("[SteriumShared] Initial ModelContainer load failed: \(error)")
        }

        // Attempt 2: SQL-repair duplicate CloudKit metadata rows and retry.
        if repairCloudKitRecordMetadataDuplicates(at: sharedStoreURL) {
            print("[SteriumShared] Retrying ModelContainer load after CloudKit metadata repair.")
            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                print("[SteriumShared] Retry after metadata repair still failed: \(error)")
            }
        }

        // Attempt 3: the store is unrecoverable through in-place migration.
        // Move the corrupt store aside so SwiftData/CloudKit can rebuild a fresh
        // one. NSPersistentCloudKitContainer re-downloads records from iCloud on
        // next launch, so CloudKit-backed data returns.
        do {
            try backupAndResetCorruptStore(at: sharedStoreURL)
            print("[SteriumShared] Reset corrupt store; retrying load with fresh store.")
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("[SteriumShared] Reset-and-rebuild failed: \(error)")
            throw error
        }
    }

    // MARK: - One-time migration from the old private sandbox store

    /// Copies Sterium's existing private-sandbox SwiftData store into the App
    /// Group location exactly once, preserving CloudKit metadata so syncing
    /// resumes seamlessly. Runs in the app only (the extension cannot see the
    /// app's private sandbox). Safe no-op if already migrated or nothing found;
    /// CloudKit is the backstop if the local copy is skipped.
    static func migrateLocalStoreToAppGroupIfNeeded() {
        let defaultsKey = "didMigrateSterumStoreToAppGroup_v1"
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: defaultsKey) else { return }

        let fileManager = FileManager.default
        let destination = sharedStoreURL

        // If the shared store already exists, do not overwrite it.
        guard !fileManager.fileExists(atPath: destination.path) else {
            defaults.set(true, forKey: defaultsKey)
            return
        }

        let searchRoots = [
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first,
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        ].compactMap { $0 }

        let oldStoreURL = searchRoots
            .flatMap { root -> [URL] in
                guard let enumerator = fileManager.enumerator(
                    at: root,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                ) else { return [] }

                var matches: [URL] = []
                while let url = enumerator.nextObject() as? URL {
                    guard url.lastPathComponent == sharedStoreFileName else { continue }
                    guard url.path != destination.path else { continue }
                    matches.append(url)
                }
                return matches
            }
            .first

        guard let oldStoreURL else {
            print("[SteriumShared] No local SwiftData store found to migrate.")
            return
        }

        do {
            for suffix in ["", "-wal", "-shm"] {
                let source = URL(fileURLWithPath: oldStoreURL.path + suffix)
                let target = URL(fileURLWithPath: destination.path + suffix)

                guard fileManager.fileExists(atPath: source.path) else { continue }
                if fileManager.fileExists(atPath: target.path) {
                    try fileManager.removeItem(at: target)
                }
                try fileManager.copyItem(at: source, to: target)
            }

            defaults.set(true, forKey: defaultsKey)
            print("[SteriumShared] Migrated local SwiftData store to App Group: \(oldStoreURL.path)")
        } catch {
            print("[SteriumShared] Failed to migrate local SwiftData store: \(error)")
        }
    }

    // MARK: - Corruption handling

    private static func backupAndResetCorruptStore(at storeURL: URL) throws {
        let fileManager = FileManager.default
        let storeDirectory = storeURL.deletingLastPathComponent()
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let backupDirectory = storeDirectory.appendingPathComponent(
            "corrupt-store-\(timestamp)",
            isDirectory: true
        )

        try fileManager.createDirectory(
            at: backupDirectory,
            withIntermediateDirectories: true
        )

        let suffixes = [
            "",
            "-wal",
            "-shm",
            "-ckAssets",
            "-ckAssets-wal",
            "-ckAssets-shm"
        ]

        for suffix in suffixes {
            let source = URL(fileURLWithPath: storeURL.path + suffix)
            guard fileManager.fileExists(atPath: source.path) else { continue }

            let destination = backupDirectory.appendingPathComponent(source.lastPathComponent)
            if fileManager.fileExists(atPath: destination.path) {
                try? fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: source, to: destination)
        }

        print("[SteriumShared] Backed up corrupt store to \(backupDirectory.path)")
    }

    private static func repairCloudKitRecordMetadataDuplicates(at storeURL: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return false }

        var database: OpaquePointer?
        let openResult = sqlite3_open_v2(
            storeURL.path,
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
            nil
        )

        guard openResult == SQLITE_OK, let database else {
            if let database {
                print("[SteriumShared] SQLite open failed: \(String(cString: sqlite3_errmsg(database)))")
                sqlite3_close(database)
            }
            return false
        }

        defer { sqlite3_close(database) }

        guard sqliteTableExists("ANSCKRECORDMETADATA", in: database) else {
            return false
        }

        let repairSQL = """
        DELETE FROM ANSCKRECORDMETADATA
        WHERE Z_PK NOT IN (
            SELECT MIN(Z_PK)
            FROM ANSCKRECORDMETADATA
            GROUP BY ZENTITYID, ZENTITYPK
        );
        DELETE FROM ANSCKRECORDMETADATA
        WHERE Z_PK NOT IN (
            SELECT MIN(Z_PK)
            FROM ANSCKRECORDMETADATA
            GROUP BY ZCKRECORDID
        );
        PRAGMA wal_checkpoint(TRUNCATE);
        VACUUM;
        """

        var errorMessage: UnsafeMutablePointer<Int8>?
        let result = sqlite3_exec(database, repairSQL, nil, nil, &errorMessage)

        if result != SQLITE_OK {
            if let errorMessage {
                print("[SteriumShared] CloudKit metadata repair failed: \(String(cString: errorMessage))")
                sqlite3_free(errorMessage)
            }
            return false
        }

        print("[SteriumShared] Repaired duplicate CloudKit metadata rows in ANSCKRECORDMETADATA.")
        return true
    }

    private static func sqliteTableExists(_ tableName: String, in database: OpaquePointer) -> Bool {
        let sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            return false
        }

        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, tableName, -1, sqliteTransient)
        return sqlite3_step(statement) == SQLITE_ROW
    }
}
