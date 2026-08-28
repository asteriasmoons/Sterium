
//
//  WorkingResultEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct WorkingResultEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \WorkingDocumentEntry.dateTime, order: .reverse)
    private var allWorkings: [WorkingDocumentEntry]

    let existing: WorkingResultEntry?

    @State private var title: String
    @State private var selectedWorking: WorkingDocumentEntry?
    @State private var date: Date
    @State private var timeSinceWorking: String
    @State private var overallOutcomeDisplay: String
    @State private var observableResults: String
    @State private var unexpectedOutcomes: String
    @State private var signsAndOmens: String
    @State private var lessonsLearned: String
    @State private var wouldRepeatDisplay: String
    @State private var changesNextTime: String
    @State private var notes: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: WorkingResultEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _selectedWorking = State(initialValue: existing?.linkedWorking)
        _date = State(initialValue: existing?.date ?? .now)
        _timeSinceWorking = State(initialValue: existing?.timeSinceWorking ?? "")
        _overallOutcomeDisplay = State(initialValue: (existing.flatMap { WorkingOutcome(rawValue: $0.overallOutcomeRawValue) } ?? .unsure).displayName)
        _observableResults = State(initialValue: existing?.observableResults ?? "")
        _unexpectedOutcomes = State(initialValue: existing?.unexpectedOutcomes ?? "")
        _signsAndOmens = State(initialValue: existing?.signsAndOmens ?? "")
        _lessonsLearned = State(initialValue: existing?.lessonsLearned ?? "")
        _wouldRepeatDisplay = State(initialValue: (existing.flatMap { RepeatDecision(rawValue: $0.wouldRepeatRawValue) } ?? .maybe).displayName)
        _changesNextTime = State(initialValue: existing?.changesNextTime ?? "")
        _notes = State(initialValue: existing?.notes ?? "")
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
                        Text("Working Result")
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

                    AsteriumTextField(title: "Title", placeholder: "Result title...", text: $title)

                    linkedWorkingPicker

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumTextField(title: "Time Since Working", placeholder: "e.g. 3 days...", text: $timeSinceWorking)

                    AsteriumPickerField(
                        title: "Overall Outcome",
                        options: WorkingOutcome.allCases.map { $0.displayName },
                        selection: $overallOutcomeDisplay
                    )

                    AsteriumTextEditor(
                        title: "Observable Results",
                        placeholder: "What results did you observe?",
                        text: $observableResults
                    )

                    AsteriumTextEditor(
                        title: "Unexpected Outcomes",
                        placeholder: "Anything unexpected?",
                        text: $unexpectedOutcomes
                    )

                    AsteriumTextEditor(
                        title: "Signs & Omens",
                        placeholder: "Any signs or omens noticed?",
                        text: $signsAndOmens
                    )

                    AsteriumTextEditor(
                        title: "Lessons Learned",
                        placeholder: "What did you learn?",
                        text: $lessonsLearned
                    )

                    AsteriumPickerField(
                        title: "Would Repeat",
                        options: RepeatDecision.allCases.map { $0.displayName },
                        selection: $wouldRepeatDisplay
                    )

                    AsteriumTextEditor(
                        title: "Changes Next Time",
                        placeholder: "What would you change?",
                        text: $changesNextTime
                    )

                    AsteriumTextEditor(
                        title: "Notes",
                        placeholder: "Any other notes...",
                        text: $notes
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

    private var linkedWorkingPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LINKED WORKING")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            Menu {
                Button("None") { selectedWorking = nil }
                ForEach(allWorkings) { working in
                    Button {
                        selectedWorking = working
                    } label: {
                        Text("\(working.title) - \(working.dateTime.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
            } label: {
                HStack {
                    if let selectedWorking {
                        Text("\(selectedWorking.title) - \(selectedWorking.dateTime.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .lineLimit(1)
                    } else {
                        Text("Choose a working...")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }
                    Spacer()
                    Text("\u{2304}")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(LGradients.header)
                }
                .padding(14)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.linkedWorking = selectedWorking
            existing.date = date
            existing.timeSinceWorking = timeSinceWorking
            existing.overallOutcomeRawValue = (WorkingOutcome.allCases.first { $0.displayName == overallOutcomeDisplay } ?? .unsure).rawValue
            existing.observableResults = observableResults
            existing.unexpectedOutcomes = unexpectedOutcomes
            existing.signsAndOmens = signsAndOmens
            existing.lessonsLearned = lessonsLearned
            existing.wouldRepeatRawValue = (RepeatDecision.allCases.first { $0.displayName == wouldRepeatDisplay } ?? .maybe).rawValue
            existing.changesNextTime = changesNextTime
            existing.notes = notes
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = WorkingResultEntry(
                title: title,
                linkedWorking: selectedWorking,
                date: date,
                timeSinceWorking: timeSinceWorking,
                overallOutcome: WorkingOutcome.allCases.first { $0.displayName == overallOutcomeDisplay } ?? .unsure,
                observableResults: observableResults,
                unexpectedOutcomes: unexpectedOutcomes,
                signsAndOmens: signsAndOmens,
                lessonsLearned: lessonsLearned,
                wouldRepeat: RepeatDecision.allCases.first { $0.displayName == wouldRepeatDisplay } ?? .maybe,
                changesNextTime: changesNextTime,
                notes: notes,
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
