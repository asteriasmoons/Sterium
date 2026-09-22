//
//  AsteriumApp.swift
//  Sterium
//

import SwiftUI
import SwiftData

@main
struct AsteriumApp: App {
    @UIApplicationDelegateAdaptor(SteriumNotificationDelegate.self) private var notificationDelegate
    @StateObject private var reportRouter = SteriumReportRouter()
    @Environment(\.scenePhase) private var scenePhase

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
                .environmentObject(reportRouter)
                .onOpenURL { url in
                    reportRouter.handleReportConversationURL(url)
                }
                .onReceive(NotificationCenter.default.publisher(
                    for: SteriumReportConversationNotificationManager.conversationNotificationOpened
                )) { notification in
                    guard let reportID = notification.object as? String else { return }
                    reportRouter.handleReportConversationID(reportID)
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    Task { await SteriumReportConversationNotificationManager.scanForNewMessages() }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
