//
//  WorkingDocumentEntryDetail.swift
//  Sterium
//

import SwiftUI

struct WorkingDocumentEntryDetail: View {
    let entry: WorkingDocumentEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Working Document", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Date & Time") {
                        detailValue(entry.dateTime.formatted(date: .long, time: .shortened))
                    }

                    GrimoireDetailSection(title: "Details") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            GrimoireDetailRow(label: "Intention", value: entry.intention, usesFrostedTile: true)
                            GrimoireDetailRow(label: "Category", value: entry.category.displayName, usesFrostedTile: true)
                            GrimoireDetailRow(label: "Kind", value: entry.workingKind.displayName, usesFrostedTile: true)
                            GrimoireDetailRow(label: "Purpose", value: entry.purpose, usesFrostedTile: true)
                        }
                    }

                    GrimoireDetailSection(title: "Ingredients & Tools") {
                        if !entry.ingredientsAndTools.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(entry.ingredientsAndTools.split(separator: "\n").enumerated()), id: \.offset) { index, item in
                                    HStack(spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(LColors.glassSurface)
                                                .overlay {
                                                    Circle()
                                                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                                                }
                                                .frame(width: 30, height: 30)

                                            Text("\(index + 1)")
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .foregroundStyle(LGradients.header)
                                        }

                                        Text(item.trimmingCharacters(in: .whitespacesAndNewlines))
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(LColors.textPrimary)
                                    }
                                }
                            }
                        }
                    }

                    GrimoireDetailSection(title: "Moon") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            GrimoireDetailRow(label: "Moon Phase", value: entry.moonPhase, usesFrostedTile: true)
                            GrimoireDetailRow(label: "Zodiac Sign", value: entry.zodiacSign, usesFrostedTile: true)
                        }
                    }

                    GrimoireDetailSection(title: "Planetary Day") {
                        detailValue(entry.planetaryDay)
                    }

                    GrimoireDetailSection(title: "Deity") {
                        detailValue(entry.deity ?? "")
                    }

                    GrimoireDetailSection(title: "Location") {
                        detailValue(entry.location)
                    }

                    GrimoireDetailSection(title: "Preparation Notes") {
                        detailValue(entry.preparationNotes)
                    }

                    if !entry.procedureSteps.isEmpty {
                        GrimoireDetailSection(title: "Procedure") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(entry.procedureSteps.split(separator: "\n").enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 10) {
                                        ZStack {
                                            Circle()
                                                .fill(LColors.glassSurface)
                                                .overlay {
                                                    Circle()
                                                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                                                }
                                                .frame(width: 30, height: 30)

                                            Text("\(index + 1)")
                                                .font(.system(size: 13, weight: .black, design: .rounded))
                                                .foregroundStyle(LGradients.header)
                                        }

                                        Text(step.trimmingCharacters(in: .whitespacesAndNewlines))
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(LColors.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }

                    GrimoireDetailSection(title: "Expectations & Notes") {
                        GrimoireDetailRow(label: "Expectations", value: entry.expectations)
                        GrimoireDetailRow(label: "Notes", value: entry.notes)
                        if !entry.results.isEmpty {
                            GrimoireDetailRow(label: "Linked Results", value: "\(entry.results.count) result\(entry.results.count == 1 ? "" : "s") recorded")
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
                WorkingDocumentEntryForm(existing: entry)
        }
    }

    private func detailValue(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
