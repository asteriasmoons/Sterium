//
//  DreamEntryDetail.swift
//  Sterium
//

import SwiftUI

struct DreamEntryDetail: View {
    let entry: DreamEntry
    @State private var showingEdit = false

    private let elementColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Dream", title: entry.title, onEdit: { showingEdit = true }) {
            overviewSection

            if !entry.dreamSummary.isEmpty {
                GrimoireDetailSection(title: "Summary") {
                    Text(entry.dreamSummary)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                }
            }

            dreamElementsSection

            GrimoireDetailSection(title: "Analysis") {
                GrimoireDetailRow(label: "Interpretation", value: entry.interpretation)
                GrimoireDetailRow(label: "Follow-Up Actions", value: entry.followUpActions)
            }

            dreamFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            DreamEntryForm(existing: entry)
        }
    }

    private var trimmedAdditionalNotes: String {
        entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var overviewSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Dream Type")
                GrimoireStatusBadge(text: entry.dreamType.displayName)
            }

            detailBox(title: "Date") {
                detailValue(entry.date.formatted(date: .long, time: .omitted))
            }

            detailBox(title: "Sleep Quality") {
                detailValue(entry.sleepQuality.displayName)
            }
        }
    }

    private var dreamElementsSection: some View {
        GrimoireDetailSection(title: "Dream Elements") {
            LazyVGrid(columns: elementColumns, spacing: 12) {
                GrimoireDetailRow(label: "Symbols", value: dreamElementValue(entry.symbols, emptyText: "No symbols"), usesFrostedTile: true, usesGradientValue: !entry.symbols.isEmpty)
                GrimoireDetailRow(label: "People", value: dreamElementValue(entry.peoplePresent, emptyText: "No people"), usesFrostedTile: true, usesGradientValue: !entry.peoplePresent.isEmpty)
                GrimoireDetailRow(label: "Animals", value: dreamElementValue(entry.animals, emptyText: "No animals"), usesFrostedTile: true, usesGradientValue: !entry.animals.isEmpty)
                GrimoireDetailRow(label: "Locations", value: dreamElementValue(entry.locations, emptyText: "No locations"), usesFrostedTile: true, usesGradientValue: !entry.locations.isEmpty)
                GrimoireDetailRow(label: "Emotions", value: dreamElementValue(entry.dominantEmotions, emptyText: "No emotions"), usesFrostedTile: true, usesGradientValue: !entry.dominantEmotions.isEmpty)
                GrimoireDetailRow(label: "Colors", value: dreamElementValue(entry.colors, emptyText: "No colors"), usesFrostedTile: true, usesGradientValue: !entry.colors.isEmpty)
            }
        }
    }

    private var dreamFooter: some View {
        Group {
            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 12) {
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
                Text(trimmedAdditionalNotes.isEmpty ? "No additional notes" : trimmedAdditionalNotes)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmedAdditionalNotes.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailBox<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: title)

            GlassCard {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func detailValue(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func dreamElementValue(_ items: [String], emptyText: String) -> String {
        items.isEmpty ? emptyText : items.joined(separator: ", ")
    }
}
