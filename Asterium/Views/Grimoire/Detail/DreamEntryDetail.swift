
//
//  DreamEntryDetail.swift
//  Asterium
//

import SwiftUI

struct DreamEntryDetail: View {
    let entry: DreamEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Dream", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Sleep Quality", value: entry.sleepQuality.displayName)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("DREAM TYPE")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
                            GrimoireStatusBadge(text: entry.dreamType.displayName)
                        }
                    }

                    if !entry.dreamSummary.isEmpty {
                        GrimoireDetailSection(title: "Summary") {
                            Text(entry.dreamSummary)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    GrimoireDetailSection(title: "Dream Elements") {
                        GrimoireDetailChips(label: "Symbols", items: entry.symbols)
                        GrimoireDetailChips(label: "People", items: entry.peoplePresent)
                        GrimoireDetailChips(label: "Animals", items: entry.animals)
                        GrimoireDetailChips(label: "Locations", items: entry.locations)
                        GrimoireDetailChips(label: "Emotions", items: entry.dominantEmotions)
                        GrimoireDetailChips(label: "Colors", items: entry.colors)
                    }

                    GrimoireDetailSection(title: "Analysis") {
                        GrimoireDetailRow(label: "Interpretation", value: entry.interpretation)
                        GrimoireDetailRow(label: "Follow-Up Actions", value: entry.followUpActions)
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                DreamEntryForm(existing: entry)
        }
    }
}