//
//  MoonPhaseEntryDetail.swift
//  Sterium
//

import SwiftUI

struct MoonPhaseEntryDetail: View {
    let entry: MoonPhaseEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Moon Phase", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Details") {
                        VStack(spacing: 12) {
                            GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted), usesFrostedTile: true)

                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ],
                                spacing: 12
                            ) {
                                GrimoireDetailRow(label: "Moon Phase", value: entry.moonPhase, usesFrostedTile: true, usesGradientValue: true)
                                GrimoireDetailRow(label: "Zodiac Sign", value: entry.zodiacSign, usesFrostedTile: true, usesGradientValue: true)
                            }
                        }
                    }

                    moodSection

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

                    stackedTileSection(title: "Intentions", items: entry.intentionItems)

                    stackedTileSection(title: "Rituals Performed", items: entry.ritualsPerformedItems)

                    stackedTileSection(title: "Manifestations", items: entry.manifestationItems)

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

                    if !entry.attachments.isEmpty {
                        GrimoireDetailSection(title: "Attachments") {
                            GrimoireAttachmentGallery(attachments: entry.attachments)
                        }
                    }

                    GrimoireRelatedEntriesList(entries: entry.relatedEntries)

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

    private func stackedTileSection(title: String, items: [String]) -> some View {
        GrimoireDetailSection(title: title) {
            VStack(alignment: .leading, spacing: 10) {
                if items.isEmpty {
                    translucentTile("No \(title.lowercased())", isEmpty: true)
                } else {
                    ForEach(items.indices, id: \.self) { index in
                        translucentTile(items[index])
                    }
                }
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: "Mood")

            FlowLayout(spacing: 8) {
                ForEach(entry.moodSelections.indices, id: \.self) { index in
                    Text(entry.moodSelections[index])
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12), in: Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                        }
                }
            }
        }
    }

    private func translucentTile(_ value: String, isEmpty: Bool = false) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
    }
}
