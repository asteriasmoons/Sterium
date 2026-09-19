//
//  DivinationEntryForm.swift
//  Sterium
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
    @State private var inquiry: String
    @State private var spreadLabel: String
    @State private var spreadQuestions: [String]
    @State private var cardSymbolItems: [DivinationCardSymbolItem]
    @State private var interpretation: String
    @State private var advice: String
    @State private var followUpItems: [String]
    @State private var accuracyReviewRating: Int

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    private static let methodOptions = [
        "Tarot",
        "Lenormand",
        "Pendulum",
        "Scrying",
        "Runes",
        "Astro Dice",
        "Bibliomancy",
        "Dreams",
        "Writing",
        "Bones",
        "Tea Leaves"
    ]

    init(existing: DivinationEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _method = State(initialValue: existing?.method ?? "")
        _inquiry = State(initialValue: existing?.questionAsked ?? "")
        _spreadLabel = State(initialValue: existing?.spreadLabel ?? existing?.spreadItems.first?.label ?? "")
        _spreadQuestions = State(initialValue: existing?.spreadQuestions ?? [])
        _cardSymbolItems = State(initialValue: existing?.cardSymbolItems ?? [])
        _interpretation = State(initialValue: existing?.interpretation ?? "")
        _advice = State(initialValue: existing?.advice ?? "")
        _followUpItems = State(initialValue: existing?.followUpItems ?? [])
        _accuracyReviewRating = State(initialValue: Int(existing?.accuracyReview ?? "") ?? 0)
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

                    AsteriumPickerField(
                        title: "Method",
                        options: Self.methodOptions,
                        selection: $method
                    )

                    AsteriumTextEditor(
                        title: "Inquiry",
                        placeholder: "What did you ask?",
                        text: $inquiry,
                        minHeight: 100
                    )

                    DivinationSpreadField(label: $spreadLabel, questions: $spreadQuestions)
                    DivinationCardSymbolField(items: $cardSymbolItems)

                    AsteriumTextEditor(
                        title: "Interpretation",
                        placeholder: "Your interpretation...",
                        text: $interpretation,
                        minHeight: 95
                    )

                    AsteriumTextEditor(
                        title: "Advice",
                        placeholder: "Guidance received...",
                        text: $advice,
                        minHeight: 95
                    )

                    DivinationFollowUpField(items: $followUpItems)
                    DivinationAccuracyField(rating: $accuracyReviewRating)

                    GrimoireUniversalFields(
                        importance: $importance,
                        tags: $tags,
                        attachments: $attachments,
                        relatedEntries: $relatedEntries,
                        additionalNotes: $additionalNotes,
                        showsSectionTitle: false
                    )

                    AsteriumPrimaryButton(title: "Save Entry") {
                        save()
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.never)
            .grimoireFormBackground()
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private func save() {
        let rating = accuracyReviewRating == 0 ? "" : String(accuracyReviewRating)

        if let existing {
            existing.title = title
            existing.date = date
            existing.method = method
            existing.questionAsked = inquiry
            existing.spreadLabel = spreadLabel.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.spreadQuestions = spreadQuestions
            existing.cardSymbolItems = cardSymbolItems
            existing.interpretation = interpretation
            existing.advice = advice
            existing.followUpItems = followUpItems
            existing.accuracyReview = rating
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
                questionAsked: inquiry,
                interpretation: interpretation,
                advice: advice,
                accuracyReview: rating,
                spreadLabel: spreadLabel.trimmingCharacters(in: .whitespacesAndNewlines),
                spreadQuestions: spreadQuestions,
                cardSymbolItems: cardSymbolItems,
                followUpItems: followUpItems,
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

private struct DivinationSpreadField: View {
    @Binding var label: String
    @Binding var questions: [String]
    @State private var questionDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            divinationFieldLabel("Spread")
            divinationInput("Label", text: $label)

            ForEach(questions.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    divinationInput("Question or focus", text: $questions[index])
                    removeButton { questions.remove(at: index) }
                }
            }

            HStack(spacing: 10) {
                divinationInput("Question or focus", text: $questionDraft)
                    .onSubmit(addItem)
                addButton(action: addItem)
            }
        }
    }

    private func addItem() {
        let question = questionDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        questions.append(question)
        questionDraft = ""
    }
}

private struct DivinationCardSymbolField: View {
    @Binding var items: [DivinationCardSymbolItem]
    @State private var nameDraft = ""
    @State private var meaningDraft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            divinationFieldLabel("Cards / Symbols Drawn")
            pairList

            VStack(spacing: 10) {
                divinationInput("Card or symbol", text: $nameDraft)
                HStack(spacing: 10) {
                    divinationInput("Meaning", text: $meaningDraft)
                        .onSubmit(addItem)
                    addButton(action: addItem)
                }
            }
        }
    }

    private var pairList: some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.name)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            if !item.meaning.isEmpty {
                                Text(item.meaning)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                            }
                        }
                        Spacer(minLength: 0)
                        removeButton { items.removeAll { $0.id == item.id } }
                    }
                    .padding(14)
                }
            }
        }
    }

    private func addItem() {
        let name = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let meaning = meaningDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty || !meaning.isEmpty else { return }
        items.append(DivinationCardSymbolItem(name: name, meaning: meaning))
        nameDraft = ""
        meaningDraft = ""
    }
}

private struct DivinationFollowUpField: View {
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            divinationFieldLabel("Follow-Up")

            HStack(spacing: 10) {
                divinationInput("Follow-up action...", text: $draft)
                    .onSubmit(addItem)
                addButton(action: addItem)
            }

            if !items.isEmpty {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Follow-Up Actions")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                Spacer()
                                Image(isExpanded ? "chevup" : "chevdown")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(LGradients.header)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if isExpanded {
                            ForEach(items.indices, id: \.self) { index in
                                HStack(spacing: 10) {
                                    Text(items[index])
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)
                                    Spacer(minLength: 0)
                                    removeButton { items.remove(at: index) }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        items.append(value)
        draft = ""
    }
}

private struct DivinationAccuracyField: View {
    @Binding var rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            divinationFieldLabel("Accuracy Review")

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        rating = rating == level ? 0 : level
                    } label: {
                        Image("starfill")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private func divinationFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func divinationInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func addButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image("addwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(LGradients.header)
            .frame(width: 44, height: 44)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
    }
    .buttonStyle(.plain)
}

private func removeButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image("xmarkwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(LGradients.header)
    }
    .buttonStyle(.plain)
}
