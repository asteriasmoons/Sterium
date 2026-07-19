
//
//  MeditationEntryDetail.swift
//  Asterium
//

import SwiftUI

struct MeditationEntryDetail: View {
    let entry: MeditationEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Meditation", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Session") {
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Duration", value: entry.durationMinutes > 0 ? "\(entry.durationMinutes) minutes" : "")
                        GrimoireDetailRow(label: "Technique", value: entry.technique)
                        GrimoireDetailRow(label: "Intention", value: entry.intention)
                        GrimoireDetailRow(label: "Environment", value: entry.environment)
                    }

                    GrimoireDetailSection(title: "Experience") {
                        GrimoireDetailRow(label: "Before Meditation", value: entry.beforeMeditation)
                        GrimoireDetailRow(label: "During Meditation", value: entry.duringMeditation)
                        GrimoireDetailRow(label: "After Meditation", value: entry.afterMeditation)
                    }

                    GrimoireDetailSection(title: "Insights") {
                        GrimoireDetailRow(label: "Insights", value: entry.insights)
                        GrimoireDetailRow(label: "Follow-Up", value: entry.followUp)
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                MeditationEntryForm(existing: entry)
        }
    }
}