//
//  ShadowWorkEntryForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct ShadowWorkEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: ShadowWorkEntry?

    @State private var title: String
    @State private var prompt: String
    @State private var date: Date
    @State private var trigger: String
    @State private var emotions: [String]
    @State private var limitingBelief: String
    @State private var originsInfluencesItems: [String]
    @State private var whatThisRevealed: String
    @State private var newPerspective: String
    @State private var actionsToPracticeItems: [String]
    @State private var affirmation: String
    @State private var reflection: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: ShadowWorkEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _prompt = State(initialValue: existing?.prompt ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _trigger = State(initialValue: existing?.trigger ?? "")
        _emotions = State(initialValue: existing?.emotions ?? [])
        _limitingBelief = State(initialValue: existing?.limitingBelief ?? "")
        _originsInfluencesItems = State(initialValue: existing?.originsInfluences ?? [])
        _whatThisRevealed = State(initialValue: existing?.whatThisRevealed ?? "")
        _newPerspective = State(initialValue: existing?.newPerspective ?? "")
        _actionsToPracticeItems = State(initialValue: existing?.actionsToPractice ?? [])
        _affirmation = State(initialValue: existing?.affirmation ?? "")
        _reflection = State(initialValue: existing?.reflection ?? "")
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
                        Text("Shadow Work")
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

                    AsteriumTextField(title: "Title", placeholder: "Shadow work title...", text: $title)

                    AsteriumTextField(title: "Prompt", placeholder: "The prompt or question...", text: $prompt)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumTextField(title: "Trigger", placeholder: "What triggered this?", text: $trigger)

                    GrimoireChipInput(title: "Emotions", placeholder: "Add emotion...", items: $emotions)

                    AsteriumTextField(title: "Limiting Belief", placeholder: "A belief to examine...", text: $limitingBelief)

                    ShadowWorkExpandableItemsField(
                        title: "Origins & Influences",
                        placeholder: "Add an origin or influence...",
                        listTitle: "Origins & Influences",
                        items: $originsInfluencesItems
                    )

                    AsteriumTextField(
                        title: "What this Revealed",
                        placeholder: "What did this reveal?",
                        text: $whatThisRevealed
                    )

                    AsteriumTextEditor(
                        title: "New Perspective",
                        placeholder: "A healthier way to see this...",
                        text: $newPerspective
                    )

                    ShadowWorkExpandableItemsField(
                        title: "Actions to Practice",
                        placeholder: "Add an action...",
                        listTitle: "Actions to Practice",
                        items: $actionsToPracticeItems
                    )

                    AsteriumTextField(title: "Affirmation", placeholder: "A positive affirmation...", text: $affirmation)

                    AsteriumTextEditor(
                        title: "Reflection",
                        placeholder: "Your reflection...",
                        text: $reflection
                    )

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
        if let existing {
            existing.title = title
            existing.prompt = prompt
            existing.date = date
            existing.trigger = trigger
            existing.emotions = emotions
            existing.limitingBelief = limitingBelief
            existing.originsInfluences = originsInfluencesItems
            existing.whatThisRevealed = whatThisRevealed
            existing.newPerspective = newPerspective
            existing.actionsToPractice = actionsToPracticeItems
            existing.affirmation = affirmation
            existing.reflection = reflection
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = ShadowWorkEntry(
                title: title,
                prompt: prompt,
                date: date,
                trigger: trigger,
                emotions: emotions,
                limitingBelief: limitingBelief,
                originsInfluences: originsInfluencesItems,
                whatThisRevealed: whatThisRevealed,
                newPerspective: newPerspective,
                actionsToPractice: actionsToPracticeItems,
                affirmation: affirmation,
                reflection: reflection,
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

private struct ShadowWorkExpandableItemsField: View {
    let title: String
    let placeholder: String
    let listTitle: String
    @Binding var items: [String]
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            shadowWorkFieldLabel(title)

            HStack(spacing: 10) {
                shadowWorkShortInput(placeholder, text: $draft)
                    .onSubmit(addItem)
                shadowWorkAddButton(action: addItem)
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
                                Text(listTitle)
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

                                    Button {
                                        items.remove(at: index)
                                    } label: {
                                        Image("xmarkwavy")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(LGradients.header)
                                    }
                                    .buttonStyle(.plain)
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

private func shadowWorkFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func shadowWorkShortInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func shadowWorkAddButton(action: @escaping () -> Void) -> some View {
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
