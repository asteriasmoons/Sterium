
//
//  DivinationEntryDetail.swift
//  Asterium
//

import SwiftUI

struct DivinationEntryDetail: View {
    let entry: DivinationEntry
    @State private var showingEdit = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Divination", title: entry.title, onEdit: { showingEdit = true }) {
                    GrimoireDetailSection(title: "Setup") {
                        GrimoireDetailRow(label: "Date", value: entry.date.formatted(date: .long, time: .omitted))
                        GrimoireDetailRow(label: "Method", value: entry.method)
                        GrimoireDetailRow(label: "Question Asked", value: entry.questionAsked)
                        GrimoireDetailRow(label: "Deck / Tool", value: entry.deckOrTool)
                        GrimoireDetailRow(label: "Spread", value: entry.spread)
                    }

                    GrimoireDetailSection(title: "Reading") {
                        GrimoireDetailRow(label: "Cards / Symbols Drawn", value: entry.cardsOrSymbolsDrawn)
                        GrimoireDetailRow(label: "Interpretation", value: entry.interpretation)
                        GrimoireDetailRow(label: "Advice", value: entry.advice)
                    }

                    GrimoireDetailSection(title: "Follow-Up") {
                        GrimoireDetailRow(label: "Follow-Up", value: entry.followUp)
                        GrimoireDetailRow(label: "Accuracy Review", value: entry.accuracyReview)
                    }

                    GrimoireDetailFooter(
                        importance: entry.importance,
                        tags: entry.tags,
                        relatedEntries: entry.relatedEntries,
                        additionalNotes: entry.additionalNotes
                    )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
                DivinationEntryForm(existing: entry)
        }
    }
}