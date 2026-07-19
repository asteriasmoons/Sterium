
//
//  WorkingDocumentEntryDetail.swift
//  Asterium
//

import SwiftUI

struct WorkingDocumentEntryDetail: View {
    let entry: WorkingDocumentEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Working Document", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        GrimoireDetailRow(label: "Date & Time", value: entry.dateTime.formatted(date: .long, time: .shortened))
                        GrimoireDetailRow(label: "Intention", value: entry.intention)
                        GrimoireDetailRow(label: "Category", value: entry.category.displayName)
                        GrimoireDetailRow(label: "Kind", value: entry.workingKind.displayName)
                        GrimoireDetailRow(label: "Purpose", value: entry.purpose)
                    }

                    GrimoireDetailSection(title: "Preparation") {
                        GrimoireDetailRow(label: "Ingredients & Tools", value: entry.ingredientsAndTools)
                        GrimoireDetailRow(label: "Moon Phase", value: entry.moonPhase)
                        GrimoireDetailRow(label: "Planetary Day", value: entry.planetaryDay)
                        GrimoireDetailRow(label: "Deity", value: entry.deity ?? "")
                        GrimoireDetailRow(label: "Location", value: entry.location)
                        GrimoireDetailRow(label: "Preparation Notes", value: entry.preparationNotes)
                    }

                    if !entry.procedureSteps.isEmpty {
                        GrimoireDetailSection(title: "Procedure") {
                            Text(entry.procedureSteps)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    GrimoireDetailSection(title: "Expectations & Notes") {
                        GrimoireDetailRow(label: "Expectations", value: entry.expectations)
                        GrimoireDetailRow(label: "Notes", value: entry.notes)
                        if !entry.results.isEmpty {
                            GrimoireDetailRow(label: "Linked Results", value: "\(entry.results.count) result\(entry.results.count == 1 ? "" : "s") recorded")
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
                WorkingDocumentEntryForm(existing: entry)
        }
    }
}