
//
//  WorkingDocumentEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct WorkingDocumentEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: WorkingDocumentEntry?

    @State private var title: String
    @State private var dateTime: Date
    @State private var intention: String
    @State private var categoryDisplay: String
    @State private var workingKindDisplay: String
    @State private var purpose: String
    @State private var ingredientsAndTools: String
    @State private var moonPhase: String
    @State private var planetaryDay: String
    @State private var deity: String
    @State private var location: String
    @State private var preparationNotes: String
    @State private var procedureSteps: String
    @State private var expectations: String
    @State private var notes: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: WorkingDocumentEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _dateTime = State(initialValue: existing?.dateTime ?? .now)
        _intention = State(initialValue: existing?.intention ?? "")
        _categoryDisplay = State(initialValue: (existing.flatMap { WorkingCategory(rawValue: $0.categoryRawValue) } ?? .other).displayName)
        _workingKindDisplay = State(initialValue: (existing.flatMap { WorkingKind(rawValue: $0.workingKindRawValue) } ?? .spell).displayName)
        _purpose = State(initialValue: existing?.purpose ?? "")
        _ingredientsAndTools = State(initialValue: existing?.ingredientsAndTools ?? "")
        _moonPhase = State(initialValue: existing?.moonPhase ?? "")
        _planetaryDay = State(initialValue: existing?.planetaryDay ?? "")
        _deity = State(initialValue: existing?.deity ?? "")
        _location = State(initialValue: existing?.location ?? "")
        _preparationNotes = State(initialValue: existing?.preparationNotes ?? "")
        _procedureSteps = State(initialValue: existing?.procedureSteps ?? "")
        _expectations = State(initialValue: existing?.expectations ?? "")
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
                        Text("Working Document")
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

                    AsteriumTextField(title: "Title", placeholder: "Working title...", text: $title)

                    AsteriumDateField(title: "Date & Time", date: $dateTime, includesTime: true)

                    AsteriumTextField(title: "Intention", placeholder: "What is your intention?", text: $intention)

                    AsteriumPickerField(
                        title: "Category",
                        options: WorkingCategory.allCases.map { $0.displayName },
                        selection: $categoryDisplay
                    )

                    AsteriumPickerField(
                        title: "Spell / Ritual",
                        options: WorkingKind.allCases.map { $0.displayName },
                        selection: $workingKindDisplay
                    )

                    AsteriumTextField(title: "Purpose", placeholder: "Purpose of working...", text: $purpose)

                    AsteriumTextEditor(
                        title: "Ingredients & Tools",
                        placeholder: "List ingredients and tools...",
                        text: $ingredientsAndTools
                    )

                    AsteriumTextField(title: "Moon Phase", placeholder: "Current moon phase...", text: $moonPhase)

                    AsteriumTextField(title: "Planetary Day", placeholder: "Day of the week / planet...", text: $planetaryDay)

                    AsteriumTextField(title: "Deity", placeholder: "Deity invoked (optional)...", text: $deity)

                    AsteriumTextField(title: "Location", placeholder: "Where performed...", text: $location)

                    AsteriumTextEditor(
                        title: "Preparation Notes",
                        placeholder: "How you prepared...",
                        text: $preparationNotes
                    )

                    AsteriumTextEditor(
                        title: "Procedure Steps",
                        placeholder: "Step-by-step procedure...",
                        text: $procedureSteps,
                        minHeight: 200
                    )

                    AsteriumTextEditor(
                        title: "Expectations",
                        placeholder: "What you expect to happen...",
                        text: $expectations
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
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.dateTime = dateTime
            existing.intention = intention
            existing.categoryRawValue = (WorkingCategory.allCases.first { $0.displayName == categoryDisplay } ?? .other).rawValue
            existing.workingKindRawValue = (WorkingKind.allCases.first { $0.displayName == workingKindDisplay } ?? .spell).rawValue
            existing.purpose = purpose
            existing.ingredientsAndTools = ingredientsAndTools
            existing.moonPhase = moonPhase
            existing.planetaryDay = planetaryDay
            existing.deity = deity.isEmpty ? nil : deity
            existing.location = location
            existing.preparationNotes = preparationNotes
            existing.procedureSteps = procedureSteps
            existing.expectations = expectations
            existing.notes = notes
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = WorkingDocumentEntry(
                title: title,
                dateTime: dateTime,
                intention: intention,
                category: WorkingCategory.allCases.first { $0.displayName == categoryDisplay } ?? .other,
                workingKind: WorkingKind.allCases.first { $0.displayName == workingKindDisplay } ?? .spell,
                purpose: purpose,
                ingredientsAndTools: ingredientsAndTools,
                moonPhase: moonPhase,
                planetaryDay: planetaryDay,
                deity: deity.isEmpty ? nil : deity,
                location: location,
                preparationNotes: preparationNotes,
                procedureSteps: procedureSteps,
                expectations: expectations,
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
