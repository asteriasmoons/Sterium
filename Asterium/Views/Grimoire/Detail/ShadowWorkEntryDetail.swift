
//
//  ShadowWorkEntryDetail.swift
//  Asterium
//

import SwiftUI

struct ShadowWorkEntryDetail: View {
    let entry: ShadowWorkEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Shadow Work", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Prompt & Trigger") {
                        GrimoireDetailRow(label: "Prompt", value: entry.prompt)
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Trigger", value: entry.trigger)
                        GrimoireDetailChips(label: "Emotions", items: entry.emotions)
                    }

                    GrimoireDetailSection(title: "Exploration") {
                        GrimoireDetailRow(label: "Limiting Belief", value: entry.limitingBelief)
                        GrimoireDetailRow(label: "Root Cause", value: entry.rootCause)
                        GrimoireDetailRow(label: "New Perspective", value: entry.newPerspective)
                    }

                    GrimoireDetailSection(title: "Integration") {
                        GrimoireDetailRow(label: "Action to Practice", value: entry.actionToPractice)
                        GrimoireDetailRow(label: "Affirmation", value: entry.affirmation)
                    }

                    if !entry.reflection.isEmpty {
                        GrimoireDetailSection(title: "Reflection") {
                            Text(entry.reflection)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                ShadowWorkEntryForm(existing: entry)
        }
    }
}