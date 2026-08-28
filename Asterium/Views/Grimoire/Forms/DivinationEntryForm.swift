
//
//  DivinationEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct DivinationEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: DivinationEntry?

    @State private var title: String
    @State private var date: Date
    @State private var method: String
    @State private var questionAsked: String
    @State private var deckOrTool: String
    @State private var spread: String
    @State private var cardsOrSymbolsDrawn: String
    @State private var interpretation: String
    @State private var advice: String
    @State private var followUp: String
    @State private var accuracyReview: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: DivinationEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _method = State(initialValue: existing?.method ?? "")
        _questionAsked = State(initialValue: existing?.questionAsked ?? "")
        _deckOrTool = State(initialValue: existing?.deckOrTool ?? "")
        _spread = State(initialValue: existing?.spread ?? "")
        _cardsOrSymbolsDrawn = State(initialValue: existing?.cardsOrSymbolsDrawn ?? "")
        _interpretation = State(initialValue: existing?.interpretation ?? "")
        _advice = State(initialValue: existing?.advice ?? "")
        _followUp = State(initialValue: existing?.followUp ?? "")
        _accuracyReview = State(initialValue: existing?.accuracyReview ?? "")
        _importance = State(initialValue: existing?.importance ?? 1)
        _tags = State(initialValue: existing?.tags ?? [])
        _attachments = State(initialValue: existing?.attachments ?? [])
        _relatedEntries = State(initialValue: existing?.relatedEntries ?? [])
        _additionalNotes = State(initialValue: existing?.additionalNotes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        Text("Divination")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)

                        Spacer()

                        Button { dismiss() } label: {
                            Image("xmarkwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    AsteriumTextField(title: "Title", placeholder: "Reading title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumTextField(title: "Method", placeholder: "e.g. Tarot, Runes, Pendulum...", text: $method)

                    AsteriumTextEditor(
                        title: "Question Asked",
                        placeholder: "What did you ask?",
                        text: $questionAsked
                    )

                    AsteriumTextField(title: "Deck or Tool", placeholder: "Which deck or tool...", text: $deckOrTool)

                    AsteriumTextField(title: "Spread", placeholder: "Spread used...", text: $spread)

                    AsteriumTextEditor(
                        title: "Cards / Symbols Drawn",
                        placeholder: "What came up...",
                        text: $cardsOrSymbolsDrawn
                    )

                    AsteriumTextEditor(
                        title: "Interpretation",
                        placeholder: "Your interpretation...",
                        text: $interpretation
                    )

                    AsteriumTextEditor(
                        title: "Advice",
                        placeholder: "Guidance received...",
                        text: $advice
                    )

                    AsteriumTextField(title: "Follow-Up", placeholder: "Follow-up actions...", text: $followUp)

                    AsteriumTextField(title: "Accuracy Review", placeholder: "How accurate was it?", text: $accuracyReview)

                    GrimoireUniversalFields(
                        importance: $importance,
                        tags: $tags,
                        attachments: $attachments,
                        relatedEntries: $relatedEntries,
                        additionalNotes: $additionalNotes
                    )

                    AsteriumPrimaryButton(title: "Save Entry") {
                        save()
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.immediately)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.date = date
            existing.method = method
            existing.questionAsked = questionAsked
            existing.deckOrTool = deckOrTool
            existing.spread = spread
            existing.cardsOrSymbolsDrawn = cardsOrSymbolsDrawn
            existing.interpretation = interpretation
            existing.advice = advice
            existing.followUp = followUp
            existing.accuracyReview = accuracyReview
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = DivinationEntry(
                title: title,
                date: date,
                method: method,
                questionAsked: questionAsked,
                deckOrTool: deckOrTool,
                spread: spread,
                cardsOrSymbolsDrawn: cardsOrSymbolsDrawn,
                interpretation: interpretation,
                advice: advice,
                followUp: followUp,
                accuracyReview: accuracyReview,
                importance: importance,
                tags: tags,
                attachments: attachments,
                relatedEntries: relatedEntries,
                additionalNotes: additionalNotes,
                createdAt: .now,
                updatedAt: .now
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
