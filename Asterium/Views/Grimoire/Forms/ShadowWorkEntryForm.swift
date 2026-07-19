
//
//  ShadowWorkEntryForm.swift
//  Asterium
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
    @State private var rootCause: String
    @State private var newPerspective: String
    @State private var actionToPractice: String
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
        _rootCause = State(initialValue: existing?.rootCause ?? "")
        _newPerspective = State(initialValue: existing?.newPerspective ?? "")
        _actionToPractice = State(initialValue: existing?.actionToPractice ?? "")
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

                    AsteriumTextEditor(
                        title: "Root Cause",
                        placeholder: "Where does this come from?",
                        text: $rootCause
                    )

                    AsteriumTextEditor(
                        title: "New Perspective",
                        placeholder: "A healthier way to see this...",
                        text: $newPerspective
                    )

                    AsteriumTextField(title: "Action to Practice", placeholder: "A concrete action...", text: $actionToPractice)

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
                        additionalNotes: $additionalNotes
                    )

                    AsteriumPrimaryButton(title: "Save Entry") {
                        save()
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 40)
            }
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.prompt = prompt
            existing.date = date
            existing.trigger = trigger
            existing.emotions = emotions
            existing.limitingBelief = limitingBelief
            existing.rootCause = rootCause
            existing.newPerspective = newPerspective
            existing.actionToPractice = actionToPractice
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
                rootCause: rootCause,
                newPerspective: newPerspective,
                actionToPractice: actionToPractice,
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
