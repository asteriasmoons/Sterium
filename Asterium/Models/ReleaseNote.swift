//
//  ReleaseNote.swift
//  Sterium
//

import Foundation

struct ReleaseNote: Identifiable {
    let id: String
    let version: String
    let build: String
    let date: String
    let summary: String
    let highlights: [String]
}

enum ReleaseNotesLibrary {
    // Newest first. Placeholder content — replace with the real changelog.
    static let all: [ReleaseNote] = [
        ReleaseNote(
            id: "1.0-b5",
            version: "Version 1.0",
            build: "Build #5",
            date: "August 2026",
            summary: "Correspondences were under inspection and I found the generic template too vague for certain types of correspondences so I have added additional correspondences for each type.",
            highlights: [
                "All 18 types of correspondences are now unique to some extent.",
                "You still may edit generated correspondences to your own liking."
            ]
        ),
        ReleaseNote(
            id: "1.0-b4",
            version: "Version 1.0",
            build: "Build #4",
            date: "August 2026",
            summary: "Spells and Correspondences are now persisted in the cloud and can be accessed from any device. You can now also build your own custom grimoire entry types and reuse them as templates for other entries.",
            highlights: [
                "Added release notes to the app for future updates to be easier read about.",
                "Build your own 'type' of entry with custom components and displays.",
                "Spells and Correspondences now sync across devices."
            ]
        ),
        ReleaseNote(
            id: "1.0-b3",
            version: "Version 1.0",
            build: "Build #3",
            date: "August 2026",
            summary: "You can generate spells and correspondences and they will save to your history.",
            highlights: [
                "Generate or create your own spells and correspondences.",
                "Edit spells and correspondences you created yourself and edit the ones you generated."
            ]
        ),
        ReleaseNote(
            id: "1.0-b2",
            version: "Version 1.0",
            build: "Build #2",
            date: "August 2026",
            summary: "Added shortcuts for everything you see on the homepage besides the lucky hours.",
            highlights: [
                "Use the new shortcuts to build daily briefs with moon info, sabbat info, planetary hour and day info, and more.",
                "Just add the Get Moon/Sabbat/Planetary Day & Hour/Current Correspondences shortcut action to your shortcut and use them as magic variables in other parts of your shortcut.",
                "To change the variable in any of these four shortcuts click on the variable to get a menu of options."
            ]
        ),
        ReleaseNote(
            id: "1.0-b1",
            version: "Version 1.0",
            build: "Build #1",
            date: "August 2026",
            summary: "Initial release of Sterium! Homepage has been redesigned and the entire app has a brand new theme.",
            highlights: [
                "Homepage with widgets for moon info, sabbat info and more.",
                "Correspondences features with AI to generate any correspondence on the spot.",
                "Spells feature with AI and experience level to generate any level of spell you need.",
                "Grimoire feature with different entry types for any type of grimoire entry you'd need."
            ]
        )
    ]

    static var latest: ReleaseNote? { all.first }
}

enum ReleaseNotesTracker {
    private static let lastSeenKey = "asterium.releaseNotes.lastSeenId"

    static var hasUnseenRelease: Bool {
        guard let latest = ReleaseNotesLibrary.latest else { return false }
        return UserDefaults.standard.string(forKey: lastSeenKey) != latest.id
    }

    static func markLatestSeen() {
        guard let latest = ReleaseNotesLibrary.latest else { return }
        UserDefaults.standard.set(latest.id, forKey: lastSeenKey)
    }
}
