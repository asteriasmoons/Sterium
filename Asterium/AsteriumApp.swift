//
//  AsteriumApp.swift
//  Sterium
//

import SwiftUI
import SwiftData

@main
struct AsteriumApp: App {
    var sharedModelContainer: ModelContainer = {
        // Move the existing private-sandbox store into the App Group once, then
        // open the single shared store (CloudKit-backed in the app).
        SteriumShared.migrateLocalStoreToAppGroupIfNeeded()

        do {
            return try SteriumShared.makeModelContainer(
                cloudKitDatabase: .private("iCloud.im.lystaria.Asterium")
            )
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
