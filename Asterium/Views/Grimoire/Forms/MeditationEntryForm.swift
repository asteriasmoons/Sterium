
//
//  MeditationEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct MeditationEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: MeditationEntry?

    @State private var title: String
    @State private var date: Date
    @State private var durationMinutesText: String
    @State private var technique: String
    @State private var intention: String
    @State private var environment: String
    @State private var beforeMeditation: String
    @State private var duringMeditation: String
    @State private var afterMeditation: String
    @State private var insights: String
    @State private var followUp: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: MeditationEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _durationMinutesText = State(initialValue: existing.map { "\($0.durationMinutes)" } ?? "")
        _technique = State(initialValue: existing?.technique ?? "")
        _intention = State(initialValue: existing?.intention ?? "")
        _environment = State(initialValue: existing?.environment ?? "")
        _beforeMeditation = State(initialValue: existing?.beforeMeditation ?? "")
        _duringMeditation = State(initialValue: existing?.duringMeditation ?? "")
        _afterMeditation = State(initialValue: existing?.afterMeditation ?? "")
        _insights = State(initialValue: existing?.insights ?? "")
        _followUp = State(initialValue: existing?.followUp ?? "")
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
                        Text("Meditation")
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

                    AsteriumTextField(title: "Title", placeholder: "Meditation title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    durationField

                    AsteriumTextField(title: "Technique", placeholder: "e.g. Breathwork, Visualization...", text: $technique)

                    AsteriumTextField(title: "Intention", placeholder: "Your intention...", text: $intention)

                    AsteriumTextField(title: "Environment", placeholder: "Where you meditated...", text: $environment)

                    AsteriumTextEditor(
                        title: "Before Meditation",
                        placeholder: "State of mind before...",
                        text: $beforeMeditation
                    )

                    AsteriumTextEditor(
                        title: "During Meditation",
                        placeholder: "What happened during...",
                        text: $duringMeditation
                    )

                    AsteriumTextEditor(
                        title: "After Meditation",
                        placeholder: "How you felt after...",
                        text: $afterMeditation
                    )

                    AsteriumTextEditor(
                        title: "Insights",
                        placeholder: "Insights gained...",
                        text: $insights
                    )

                    AsteriumTextField(title: "Follow-Up", placeholder: "Next steps...", text: $followUp)

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

    private var durationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DURATION (MINUTES)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            TextField("0", text: $durationMinutesText)
                .keyboardType(.numberPad)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .padding(14)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
        }
    }

    private func save() {
        let duration = Int(durationMinutesText) ?? 0

        if let existing {
            existing.title = title
            existing.date = date
            existing.durationMinutes = duration
            existing.technique = technique
            existing.intention = intention
            existing.environment = environment
            existing.beforeMeditation = beforeMeditation
            existing.duringMeditation = duringMeditation
            existing.afterMeditation = afterMeditation
            existing.insights = insights
            existing.followUp = followUp
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = MeditationEntry(
                title: title,
                date: date,
                durationMinutes: duration,
                technique: technique,
                intention: intention,
                environment: environment,
                beforeMeditation: beforeMeditation,
                duringMeditation: duringMeditation,
                afterMeditation: afterMeditation,
                insights: insights,
                followUp: followUp,
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
