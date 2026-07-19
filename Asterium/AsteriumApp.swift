//
//  AsteriumApp.swift
//  Asterium
//
//  Created by Asteria Moon on 7/17/26.
//

import SwiftUI
import SwiftData

@main
struct AsteriumApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
