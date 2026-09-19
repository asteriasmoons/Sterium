//
//  AsteriumShortcuts.swift
//  Sterium
//
//  Discoverability provider for the four Asterium App Intents,
//  making them appear under Asterium in Apple Shortcuts.
//

import AppIntents

struct AsteriumShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentMoonIntent(),
            phrases: [
                "Get current moon in \(.applicationName)",
                "Current moon from \(.applicationName)"
            ],
            shortTitle: "Get Current Moon",
            systemImageName: "moon.stars.fill"
        )

        AppShortcut(
            intent: GetUpcomingSabbatIntent(),
            phrases: [
                "Get upcoming sabbat in \(.applicationName)",
                "Next sabbat from \(.applicationName)"
            ],
            shortTitle: "Get Upcoming Sabbat",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: GetPlanetaryDayHourIntent(),
            phrases: [
                "Get planetary day and hour in \(.applicationName)",
                "Planetary hour from \(.applicationName)"
            ],
            shortTitle: "Get Planetary Day & Hour",
            systemImageName: "clock.fill"
        )

        AppShortcut(
            intent: GetCurrentCorrespondencesIntent(),
            phrases: [
                "Get current correspondences in \(.applicationName)",
                "Today's correspondences from \(.applicationName)"
            ],
            shortTitle: "Get Current Correspondences",
            systemImageName: "sparkles"
        )
    }
}
