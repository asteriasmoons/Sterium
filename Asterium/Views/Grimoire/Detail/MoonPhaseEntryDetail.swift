
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
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Moon Phase", value: entry.moonPhase)
                        GrimoireDetailRow(label: "Zodiac Sign", value: entry.zodiacSign)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("ENERGY LEVEL")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)
                            HStack(spacing: 6) {
                                ForEach(1...5, id: \.self) { i in
                                    Circle()
                                        .fill(i <= entry.energyLevel ? AnyShapeStyle(LGradients.tag) : AnyShapeStyle(LColors.glassSurface))
                                        .frame(width: 12, height: 12)
                                        .overlay {
                                            Circle()
                                                .strokeBorder(i <= entry.energyLevel ? Color.clear : LColors.glassBorder, lineWidth: 1)
                                        }
                                }
                            }
                        }

                        GrimoireDetailRow(label: "Mood", value: entry.mood)
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

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                MoonPhaseEntryForm(existing: entry)
        }
    }
}