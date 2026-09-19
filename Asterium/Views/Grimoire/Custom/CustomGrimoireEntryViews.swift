//
// CustomGrimoireEntryViews.swift
// Sterium
//

import SwiftUI
import SwiftData

struct CustomGrimoireEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let template: CustomGrimoireTemplate?
    private let existing: CustomGrimoireEntry?
    private let templateName: String
    private let templateIconName: String
    private let templateID: UUID
    private let templateVersion: Int

    @State private var schema: CustomGrimoireSchema
    @State private var values: [UUID: CustomFieldValue]
    @State private var showingValidation = false

    init(template: CustomGrimoireTemplate) {
        let schema = CustomGrimoireCoding.decodeSchema(template.currentSchemaData)
        self.template = template
        self.existing = nil
        self.templateName = template.name
        self.templateIconName = template.iconName
        self.templateID = template.id
        self.templateVersion = template.currentVersion
        _schema = State(initialValue: schema)
        _values = State(initialValue: Dictionary(uniqueKeysWithValues: schema.fields.map { ($0.id, .empty(for: $0)) }))
    }

    init(existing: CustomGrimoireEntry) {
        let schema = CustomGrimoireCoding.decodeSchema(existing.schemaSnapshotData)
        var stored = CustomGrimoireCoding.decodeValues(existing.valuesData)
        for field in schema.fields where stored[field.id] == nil { stored[field.id] = .empty(for: field) }
        self.template = nil
        self.existing = existing
        self.templateName = existing.templateName
        self.templateIconName = existing.templateIconName
        self.templateID = existing.templateID
        self.templateVersion = existing.templateVersion
        _schema = State(initialValue: schema)
        _values = State(initialValue: stored)
    }

    private var missingRequiredLabels: [String] {
        schema.fields.filter { $0.isRequired && isEmpty(values[$0.id] ?? .empty(for: $0)) }.map(\.label)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        HStack {
                            AsteriumPageHeader(eyebrow: "CUSTOM ENTRY", title: templateName)
                            Spacer()
                            Button { dismiss() } label: {
                                Image("xmarkwavy").renderingMode(.template).resizable().scaledToFit()
                                    .frame(width: 24, height: 24).foregroundStyle(LGradients.header)
                            }.buttonStyle(.plain)
                        }

                        if showingValidation, !missingRequiredLabels.isEmpty {
                            GlassCard(padding: 14) {
                                Text("Complete: \(missingRequiredLabels.joined(separator: ", "))")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(LGradients.header)
                            }
                        }

                        CustomGrimoireFormFields(schema: schema, values: $values)

                        AsteriumPrimaryButton(title: existing == nil ? "Save Entry" : "Save Changes") {
                            save()
                        }
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.never)
                .grimoireFormBackground()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private func isEmpty(_ value: CustomFieldValue) -> Bool {
        switch value {
        case let .text(value): return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case let .number(value): return value == nil
        case .date: return false
        case .boolean: return false
        case let .strings(value): return value.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.isEmpty
        case let .pairs(value): return value.filter { !$0.first.isEmpty || !$0.second.isEmpty }.isEmpty
        case let .rating(value): return value == 0
        case let .attachments(value): return value.isEmpty
        case let .relationships(value): return value.isEmpty
        case let .dependentChoice(value): return value.parent.isEmpty && value.child.isEmpty
        }
    }

    private func save() {
        guard missingRequiredLabels.isEmpty else {
            showingValidation = true
            return
        }

        let title = schema.fields.first(where: { $0.semanticRole == .entryTitle })
            .flatMap { values[$0.id]?.displayText }
            .flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 } ?? "Untitled"
        let entryDate = schema.fields.first(where: { $0.semanticRole == .entryDate })
            .flatMap { field -> Date? in
                guard case let .date(date) = values[field.id] else { return nil }
                return date
            } ?? .now
        let valueData = CustomGrimoireCoding.encodeValues(values)

        if let existing {
            existing.title = title
            existing.entryDate = entryDate
            existing.valuesData = valueData
            existing.updatedAt = .now
        } else {
            modelContext.insert(CustomGrimoireEntry(
                templateID: templateID,
                templateVersion: templateVersion,
                templateName: templateName,
                templateIconName: templateIconName,
                title: title,
                entryDate: entryDate,
                schemaSnapshotData: CustomGrimoireCoding.encodeSchema(schema),
                valuesData: valueData
            ))
        }
        try? modelContext.save()
        dismiss()
    }
}

struct CustomGrimoireEntryDetail: View {
    @Environment(\.modelContext) private var modelContext
    let entry: CustomGrimoireEntry

    @State private var schema: CustomGrimoireSchema
    @State private var values: [UUID: CustomFieldValue]
    @State private var showingEdit = false

    init(entry: CustomGrimoireEntry) {
        self.entry = entry
        let schema = CustomGrimoireCoding.decodeSchema(entry.schemaSnapshotData)
        _schema = State(initialValue: schema)
        _values = State(initialValue: CustomGrimoireCoding.decodeValues(entry.valuesData))
    }

    var body: some View {
        GrimoireDetailScaffold(eyebrow: entry.templateName, title: entry.title, onEdit: { showingEdit = true }) {
            CustomGrimoireDisplay(
                schema: schema,
                values: $values,
                allowsInlineEditing: true,
                onValuesChanged: persistInlineChanges
            )
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            CustomGrimoireEntryForm(existing: entry)
        }
        .onChange(of: showingEdit) { _, isShowing in
            if !isShowing { reload() }
        }
    }

    private func reload() {
        schema = CustomGrimoireCoding.decodeSchema(entry.schemaSnapshotData)
        values = CustomGrimoireCoding.decodeValues(entry.valuesData)
    }

    private func persistInlineChanges() {
        entry.valuesData = CustomGrimoireCoding.encodeValues(values)
        entry.updatedAt = .now
        if let titleField = schema.fields.first(where: { $0.semanticRole == .entryTitle }),
           let title = values[titleField.id]?.displayText,
           !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            entry.title = title
        }
        try? modelContext.save()
    }
}
