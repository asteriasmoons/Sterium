
//
//  MoonPhaseEntryDetail.swift
//  Asterium
//

import SwiftUI

struct MoonPhaseEntryDetail: View {
    let entry: MoonPhaseEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Moon Phase", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Details") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted), usesFrostedTile: true)
                            GrimoireDetailRow(label: "Moon Phase", value: entry.moonPhase, usesFrostedTile: true, usesGradientValue: true)
                            GrimoireDetailRow(label: "Zodiac Sign", value: entry.zodiacSign, usesFrostedTile: true, usesGradientValue: true)
                            GrimoireDetailRow(label: "Mood", value: entry.mood, usesFrostedTile: true, usesGradientValue: true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        AsteriumSectionHeader(title: "Energy")

                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { i in
                                Circle()
                                    .fill(i <= entry.energyLevel ? AnyShapeStyle(LGradients.tag) : AnyShapeStyle(LColors.glassSurface))
                                    .frame(width: 14, height: 14)
                                    .overlay {
                                        Circle()
                                            .strokeBorder(i <= entry.energyLevel ? Color.clear : LColors.glassBorder, lineWidth: 1)
                                    }
                            }
                        }
                    }

                    GrimoireDetailSection(title: "Practice") {
                        GrimoireDetailRow(label: "Intentions", value: entry.intentions)
                        GrimoireDetailRow(label: "Rituals Performed", value: entry.ritualsPerformed)
                        GrimoireDetailRow(label: "Manifestations", value: entry.manifestations)
                    }

                    if !entry.reflections.isEmpty {
                        GrimoireDetailSection(title: "Reflections") {
                            Text(entry.reflections)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        AsteriumSectionHeader(title: "Importance")
                        GrimoireImportanceDots(value: entry.importance, showsLabel: false)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        AsteriumSectionHeader(title: "Tags")
                        GrimoireDetailChips(label: "Tags", items: entry.tags, showsLabel: false)
                    }

                    GrimoireDetailSection(title: "Related Entries") {
                        GrimoireRelatedEntriesList(entries: entry.relatedEntries, showsLabel: false)
                    }

                    GrimoireDetailSection(title: "Additional Notes") {
                        Text(entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No additional notes" : entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                MoonPhaseEntryForm(existing: entry)
        }
    }
}