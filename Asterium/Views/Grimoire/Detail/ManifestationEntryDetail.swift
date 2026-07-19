
//
//  ManifestationEntryDetail.swift
//  Asterium
//

import SwiftUI

struct ManifestationEntryDetail: View {
    let entry: ManifestationEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Manifestation", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Overview") {
                        GrimoireDetailRow(label: "Date Started", value: entry.dateStarted.formatted(date: .long, time: .omitted))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("STATUS")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
                            GrimoireStatusBadge(text: entry.manifestationStatus.displayName)
                        }

                        GrimoireDetailRow(label: "Desire", value: entry.desire)
                        GrimoireDetailRow(label: "Why It Matters", value: entry.whyItMatters)
                    }

                    GrimoireDetailSection(title: "Practice") {
                        GrimoireDetailRow(label: "Intention", value: entry.intention)
                        GrimoireDetailRow(label: "Visualization", value: entry.visualization)
                        GrimoireDetailRow(label: "Inspired Actions", value: entry.inspiredActions)
                    }

                    GrimoireDetailSection(title: "Progress") {
                        GrimoireDetailRow(label: "Obstacles", value: entry.obstacles)
                        GrimoireDetailRow(label: "Evidence of Progress", value: entry.evidenceOfProgress)
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
                ManifestationEntryForm(existing: entry)
        }
    }
}