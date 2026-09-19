//
// CustomGrimoireTemplateBuilder.swift
// Sterium
//

import SwiftUI
import SwiftData

struct CustomGrimoireTemplateBuilder: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: CustomGrimoireTemplate?

    @State private var name: String
    @State private var iconName: String
    @State private var schema: CustomGrimoireSchema
    @State private var previewValues: [UUID: CustomFieldValue]
    @State private var showingComponentPicker = false
    @State private var editingFieldID: UUID?
    @State private var editingSectionID: UUID?
    @State private var showingFormPreview = false
    @State private var showingDisplayPreview = false

    init(existing: CustomGrimoireTemplate? = nil) {
        self.existing = existing
        let initialSchema = existing.map { CustomGrimoireCoding.decodeSchema($0.currentSchemaData) } ?? .starter()
        _name = State(initialValue: existing?.name ?? "")
        _iconName = State(initialValue: existing?.iconName ?? "grimoire")
        _schema = State(initialValue: initialSchema)
        _previewValues = State(initialValue: Dictionary(uniqueKeysWithValues: initialSchema.fields.map { ($0.id, .empty(for: $0)) }))
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        schema.fields.contains(where: { $0.semanticRole == .entryTitle })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        header
                        identitySection
                        fieldsSection
                        displaySectionsSection
                        previewButtons

                        AsteriumPrimaryButton(title: existing == nil ? "Save Entry Type" : "Save New Version") {
                            save()
                        }
                        .opacity(canSave ? 1 : 0.45)
                        .disabled(!canSave)
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal)
                    .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.never)
                .grimoireFormBackground()
            }
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(isPresented: $showingComponentPicker) {
                CustomComponentPicker { kind in addField(kind) }
            }
            .asteriumAdaptivePresentation(isPresented: fieldEditorPresented) {
                if let field = editingFieldBinding {
                    CustomFieldDefinitionEditor(field: field, schema: schema) {
                        normalizeSchema()
                    }
                }
            }
            .asteriumAdaptivePresentation(isPresented: sectionEditorPresented) {
                if let section = editingSectionBinding {
                    CustomDisplaySectionEditor(section: section)
                }
            }
            .asteriumAdaptivePresentation(isPresented: $showingFormPreview) {
                CustomTemplateFormPreview(schema: schema, values: $previewValues)
            }
            .asteriumAdaptivePresentation(isPresented: $showingDisplayPreview) {
                CustomTemplateDisplayPreview(name: name, schema: schema, values: $previewValues)
            }
        }
        .presentationDetents([.large])
        .presentationContentInteraction(.scrolls)
    }

    private var header: some View {
        HStack {
            AsteriumPageHeader(
                eyebrow: "CUSTOM GRIMOIRE",
                title: existing == nil ? "New Entry Type" : "Edit Entry Type"
            )
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
    }

    private var identitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumTextField(title: "Entry Type Name", placeholder: "e.g. Herbal Study...", text: $name)
            AsteriumSectionHeader(title: "Icon")
            IconPickerView(selection: $iconName)
        }
    }

    private var fieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsteriumSectionHeader(title: "Form Components")
                Spacer()
                Button { showingComponentPicker = true } label: { builderIcon("addwavy") }
                    .buttonStyle(.plain)
            }

            ForEach(Array(schema.fields.enumerated()), id: \.element.id) { index, field in
                builderCard {
                    HStack(spacing: 12) {
                        Image(field.componentKind.iconName)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(LGradients.header)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(field.label)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            Text(field.componentKind.displayName)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                        }
                        Spacer()
                        reorderButtons(index: index, count: schema.fields.count) { from, to in
                            schema.fields.swapAt(from, to)
                        }
                        Button { editingFieldID = field.id } label: { builderIcon("pencil", size: 18) }
                            .buttonStyle(.plain)
                        Button { removeField(field.id) } label: { builderIcon("trash", size: 17) }
                            .buttonStyle(.plain)
                            .disabled(field.semanticRole == .entryTitle)
                            .opacity(field.semanticRole == .entryTitle ? 0.3 : 1)
                    }
                }
            }
        }
    }

    private var displaySectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsteriumSectionHeader(title: "Display Sections")
                Spacer()
                Button { addSection() } label: { builderIcon("addwavy") }
                    .buttonStyle(.plain)
            }

            ForEach(Array(schema.displaySections.sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, section in
                builderCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image("threeboxes")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(LGradients.header)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(section.title.isEmpty ? "Untitled Section" : section.title)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                Text(section.containerKind.displayName)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                            }
                            Spacer()
                            reorderButtons(index: index, count: schema.displaySections.count) { from, to in
                                moveSection(from: from, to: to)
                            }
                            Button { editingSectionID = section.id } label: { builderIcon("pencil", size: 18) }
                                .buttonStyle(.plain)
                            Button { removeSection(section.id) } label: { builderIcon("trash", size: 17) }
                                .buttonStyle(.plain)
                                .disabled(schema.displaySections.count == 1)
                                .opacity(schema.displaySections.count == 1 ? 0.3 : 1)
                        }

                        let displayFields = schema.fields
                            .filter { $0.displaySectionID == section.id && $0.semanticRole != .entryTitle }
                            .sorted { $0.displayOrder < $1.displayOrder }
                        ForEach(Array(displayFields.enumerated()), id: \.element.id) { fieldIndex, field in
                            HStack(spacing: 10) {
                                Text(field.label)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                Text(field.displayRenderer.displayName)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                                    .lineLimit(1)
                                reorderButtons(index: fieldIndex, count: displayFields.count) { from, to in
                                    moveDisplayField(in: section.id, from: from, to: to)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }

    private var previewButtons: some View {
        HStack(spacing: 12) {
            compactAction(title: "Preview Form", asset: "linedpages") { showingFormPreview = true }
            compactAction(title: "Preview Display", asset: "eye") { showingDisplayPreview = true }
        }
    }

    private func compactAction(title: String, asset: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(asset).renderingMode(.template).resizable().scaledToFit().frame(width: 17, height: 17)
                Text(title).font(.system(size: 13, weight: .black, design: .rounded))
            }
            .foregroundStyle(LGradients.header)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }

    private func builderCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        GlassCard(cornerRadius: LSpacing.cardRadius, padding: 14) { content() }
    }

    private func builderIcon(_ asset: String, size: CGFloat = 20) -> some View {
        Image(asset)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(LGradients.header)
            .frame(width: 34, height: 34)
    }

    private func reorderButtons(index: Int, count: Int, move: @escaping (Int, Int) -> Void) -> some View {
        HStack(spacing: 2) {
            Button { if index > 0 { move(index, index - 1) } } label: { builderIcon("upwavy", size: 14) }
                .buttonStyle(.plain).disabled(index == 0).opacity(index == 0 ? 0.25 : 1)
            Button { if index + 1 < count { move(index, index + 1) } } label: { builderIcon("downwavy", size: 14) }
                .buttonStyle(.plain).disabled(index + 1 == count).opacity(index + 1 == count ? 0.25 : 1)
        }
    }

    private var fieldEditorPresented: Binding<Bool> {
        Binding(get: { editingFieldID != nil }, set: { if !$0 { editingFieldID = nil } })
    }

    private var sectionEditorPresented: Binding<Bool> {
        Binding(get: { editingSectionID != nil }, set: { if !$0 { editingSectionID = nil } })
    }

    private var editingFieldBinding: Binding<CustomFieldDefinition>? {
        guard let id = editingFieldID, let index = schema.fields.firstIndex(where: { $0.id == id }) else { return nil }
        return $schema.fields[index]
    }

    private var editingSectionBinding: Binding<CustomDisplaySectionDefinition>? {
        guard let id = editingSectionID, let index = schema.displaySections.firstIndex(where: { $0.id == id }) else { return nil }
        return $schema.displaySections[index]
    }

    private func addField(_ kind: CustomFormComponentKind) {
        guard let section = schema.displaySections.sorted(by: { $0.order < $1.order }).first else { return }
        let renderer = CustomDisplayRendererKind.compatible(with: kind.valueType).first ?? .plainText
        let field = CustomFieldDefinition(
            label: kind.displayName,
            placeholder: defaultPlaceholder(for: kind),
            componentKind: kind,
            displaySectionID: section.id,
            displayRenderer: renderer,
            displayOrder: schema.fields.filter { $0.displaySectionID == section.id }.count
        )
        schema.fields.append(field)
        previewValues[field.id] = .empty(for: field)
        showingComponentPicker = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { editingFieldID = field.id }
    }

    private func defaultPlaceholder(for kind: CustomFormComponentKind) -> String {
        switch kind {
        case .paragraph, .conditionalText: return "Enter details..."
        case .number: return "0"
        case .createToAddList, .freeEntryValues, .repeatableList, .dynamicSteps, .inlineEditableList, .tags: return "Type a value..."
        default: return "Enter value..."
        }
    }

    private func removeField(_ id: UUID) {
        schema.fields.removeAll { $0.id == id }
        previewValues.removeValue(forKey: id)
        normalizeSchema()
    }

    private func addSection() {
        schema.displaySections.append(CustomDisplaySectionDefinition(title: "New Section", order: schema.displaySections.count))
    }

    private func removeSection(_ id: UUID) {
        guard schema.displaySections.count > 1,
              let fallback = schema.displaySections.first(where: { $0.id != id }) else { return }
        for index in schema.fields.indices where schema.fields[index].displaySectionID == id {
            schema.fields[index].displaySectionID = fallback.id
        }
        schema.displaySections.removeAll { $0.id == id }
        normalizeSchema()
    }

    private func moveSection(from: Int, to: Int) {
        var ordered = schema.displaySections.sorted { $0.order < $1.order }
        guard ordered.indices.contains(from), ordered.indices.contains(to) else { return }
        ordered.swapAt(from, to)
        for index in ordered.indices { ordered[index].order = index }
        schema.displaySections = ordered
    }

    private func normalizeSchema() {
        if let preferredID = editingFieldID,
           let edited = schema.fields.first(where: { $0.id == preferredID }),
           edited.semanticRole != .none {
            for index in schema.fields.indices where schema.fields[index].id != preferredID && schema.fields[index].semanticRole == edited.semanticRole {
                schema.fields[index].semanticRole = .none
            }
        }
        for sectionIndex in schema.displaySections.indices { schema.displaySections[sectionIndex].order = sectionIndex }
        for section in schema.displaySections {
            let orderedIDs = schema.fields
                .filter { $0.displaySectionID == section.id }
                .sorted { $0.displayOrder < $1.displayOrder }
                .map(\.id)
            for (order, id) in orderedIDs.enumerated() {
                if let index = schema.fields.firstIndex(where: { $0.id == id }) { schema.fields[index].displayOrder = order }
            }
        }
        for field in schema.fields where previewValues[field.id] == nil { previewValues[field.id] = .empty(for: field) }
    }

    private func moveDisplayField(in sectionID: UUID, from: Int, to: Int) {
        var fields = schema.fields.filter { $0.displaySectionID == sectionID }.sorted { $0.displayOrder < $1.displayOrder }
        guard fields.indices.contains(from), fields.indices.contains(to) else { return }
        fields.swapAt(from, to)
        for (order, field) in fields.enumerated() {
            if let index = schema.fields.firstIndex(where: { $0.id == field.id }) {
                schema.fields[index].displayOrder = order
            }
        }
    }

    private func save() {
        normalizeSchema()
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = CustomGrimoireCoding.encodeSchema(schema)

        if let existing {
            let nextVersion = existing.currentVersion + 1
            existing.name = cleanName
            existing.iconName = iconName
            existing.currentVersion = nextVersion
            existing.currentSchemaData = data
            existing.updatedAt = .now
            modelContext.insert(CustomGrimoireTemplateVersion(
                templateID: existing.id,
                version: nextVersion,
                name: cleanName,
                iconName: iconName,
                schemaData: data
            ))
        } else {
            let template = CustomGrimoireTemplate(
                name: cleanName,
                iconName: iconName,
                currentVersion: 1,
                currentSchemaData: data
            )
            modelContext.insert(template)
            modelContext.insert(CustomGrimoireTemplateVersion(
                templateID: template.id,
                version: 1,
                name: cleanName,
                iconName: iconName,
                schemaData: data
            ))
        }
        try? modelContext.save()
        dismiss()
    }
}

private struct CustomComponentPicker: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (CustomFormComponentKind) -> Void
    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ZStack {
            AsteriumBackground().ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack {
                        AsteriumPageHeader(eyebrow: "CUSTOM FORM", title: "Add Component")
                        Spacer()
                        Button { dismiss() } label: { builderAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
                    }
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(CustomFormComponentKind.allCases) { kind in
                            Button { onSelect(kind) } label: {
                                GlassCard(padding: 14) {
                                    VStack(spacing: 9) {
                                        Image(kind.iconName).renderingMode(.template).resizable().scaledToFit()
                                            .frame(width: 25, height: 25).foregroundStyle(LGradients.header)
                                        Text(kind.displayName)
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundStyle(LColors.textPrimary)
                                            .multilineTextAlignment(.center).lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity).frame(minHeight: 68)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 80)
            }
        }
    }
}

private struct CustomFieldDefinitionEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var field: CustomFieldDefinition
    let schema: CustomGrimoireSchema
    let onDone: () -> Void

    @State private var optionsDraft: [String] = []
    @State private var firstOptionsDraft: [String] = []
    @State private var dependentPairs: [CustomPairValue] = []
    @State private var sectionChoice = ""
    @State private var rendererChoice = ""
    @State private var semanticChoice = ""
    @State private var conditionChoice = "Always"

    private var sections: [CustomDisplaySectionDefinition] { schema.displaySections.sorted { $0.order < $1.order } }
    private var sectionOptions: [String] { sections.enumerated().map { "\($0.offset + 1). \($0.element.title.isEmpty ? "Untitled Section" : $0.element.title)" } }
    private var compatibleRenderers: [CustomDisplayRendererKind] {
        CustomDisplayRendererKind.compatible(with: field.valueType)
    }
    private var rendererOptions: [String] { compatibleRenderers.map(\.displayName) }
    private var conditionFields: [CustomFieldDefinition] { schema.fields.filter { $0.id != field.id } }
    private var conditionOptions: [String] { ["Always"] + conditionFields.enumerated().map { "\($0.offset + 1). \($0.element.label)" } }
    private var semanticOptions: [String] {
        switch field.valueType {
        case .text, .number, .strings:
            return [CustomFieldSemanticRole.none.displayName, CustomFieldSemanticRole.entryTitle.displayName]
        case .date:
            return [CustomFieldSemanticRole.none.displayName, CustomFieldSemanticRole.entryDate.displayName]
        default:
            return [CustomFieldSemanticRole.none.displayName]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        HStack {
                            AsteriumPageHeader(eyebrow: "FORM COMPONENT", title: field.componentKind.displayName)
                            Spacer()
                            Button { finish() } label: { builderAsset("checkwavy", size: 24) }.buttonStyle(.plain)
                            Button { dismiss() } label: { builderAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
                        }
                        AsteriumTextField(title: "Label", placeholder: "Field label...", text: $field.label)
                        if ![.date, .dateTime, .yesNo, .importance, .attachments, .relatedEntries, .relationshipSelector].contains(field.componentKind) {
                            AsteriumTextField(title: "Placeholder", placeholder: "Input hint...", text: $field.placeholder)
                        }
                        yesNoSetting(title: "Required", value: $field.isRequired)
                        AsteriumPickerField(title: "Semantic Role", options: semanticOptions, selection: $semanticChoice)

                        componentSettings

                        AsteriumSectionHeader(title: "Display Mapping")
                        AsteriumPickerField(title: "Section", options: sectionOptions, selection: $sectionChoice)
                        AsteriumPickerField(title: "Display Style", options: rendererOptions, selection: $rendererChoice)
                        yesNoSetting(title: "Hide Field Label", value: hidesFieldLabelBinding)

                        AsteriumSectionHeader(title: "Conditional Visibility")
                        AsteriumPickerField(title: "Show This Field When", options: conditionOptions, selection: $conditionChoice)
                        if conditionChoice != "Always" {
                            AsteriumTextField(title: "Value Equals", placeholder: "Expected value...", text: conditionalExpectedBinding)
                        }
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.never)
                .grimoireFormBackground()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear { initialize() }
    }

    @ViewBuilder
    private var componentSettings: some View {
        switch field.componentKind {
        case .singleSelect, .multiSelect:
            CustomExpandableListField(title: "Options", placeholder: "Add option...", listTitle: "Options", items: $optionsDraft, maximumItems: 100)
            yesNoSetting(title: "Allow Custom Value", value: $field.allowsCustomValue)
            if field.allowsCustomValue {
                AsteriumTextField(title: "Custom Option Label", placeholder: "Custom", text: $field.customValueLabel)
            }
        case .createToAddList, .freeEntryValues, .repeatableList, .dynamicSteps, .inlineEditableList, .tags:
            maximumItemsSetting
        case .repeatableGroup, .repeatedPairs:
            AsteriumTextField(title: "First Value Label", placeholder: "Label...", text: $field.pairFirstLabel)
            AsteriumTextField(title: "Second Value Label", placeholder: "Description...", text: $field.pairSecondLabel)
            CustomExpandableListField(title: "First Value Options", placeholder: "Optional preset...", listTitle: "Presets", items: $firstOptionsDraft, maximumItems: 100)
            maximumItemsSetting
        case .numberRating, .dotRating, .starRating, .importance:
            ratingMaximumSetting
        case .dependentSelector:
            AsteriumTextField(title: "Primary Label", placeholder: "Environment...", text: $field.pairFirstLabel)
            AsteriumTextField(title: "Dependent Label", placeholder: "Location...", text: $field.pairSecondLabel)
            CustomPairConfigurationField(pairs: $dependentPairs)
        default:
            EmptyView()
        }
    }

    private var maximumItemsSetting: some View {
        CustomIntegerStepper(title: "Maximum Items", value: $field.maximumItems, range: 1...100)
    }

    private var ratingMaximumSetting: some View {
        CustomIntegerStepper(title: "Maximum Rating", value: $field.ratingMaximum, range: 2...10)
    }

    private var hidesFieldLabelBinding: Binding<Bool> {
        Binding(
            get: { field.hidesFieldLabel ?? false },
            set: { field.hidesFieldLabel = $0 }
        )
    }

    private var conditionalExpectedBinding: Binding<String> {
        Binding(
            get: { field.conditionalRule?.expectedValue ?? "" },
            set: { value in
                guard let source = selectedConditionField else { return }
                field.conditionalRule = CustomConditionalRule(sourceFieldID: source.id, expectedValue: value)
            }
        )
    }

    private var selectedConditionField: CustomFieldDefinition? {
        guard conditionChoice != "Always", let index = conditionOptions.firstIndex(of: conditionChoice), index > 0 else { return nil }
        return conditionFields[index - 1]
    }

    private func yesNoSetting(title: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(LColors.textSecondary)
            HStack(spacing: 10) {
                settingChoice("Yes", selected: value.wrappedValue) { value.wrappedValue = true }
                settingChoice("No", selected: !value.wrappedValue) { value.wrappedValue = false }
            }
        }
    }

    private func settingChoice(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(selected ? LColors.bg : LColors.textPrimary)
                .frame(maxWidth: .infinity).padding(.vertical, 11)
                .background(selected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface), in: Capsule())
        }.buttonStyle(.plain)
    }

    private func initialize() {
        optionsDraft = field.options
        firstOptionsDraft = field.pairFirstOptions
        dependentPairs = field.dependentGroups.map { CustomPairValue(id: $0.id, first: $0.parentValue, second: $0.childOptions.joined(separator: ", ")) }
        semanticChoice = field.semanticRole.displayName
        rendererChoice = field.displayRenderer.displayName
        if let index = sections.firstIndex(where: { $0.id == field.displaySectionID }) { sectionChoice = sectionOptions[index] }
        if let rule = field.conditionalRule, let index = conditionFields.firstIndex(where: { $0.id == rule.sourceFieldID }) {
            conditionChoice = conditionOptions[index + 1]
        }
    }

    private func finish() {
        field.options = optionsDraft
        field.pairFirstOptions = firstOptionsDraft
        field.dependentGroups = dependentPairs.compactMap { pair in
            let parent = pair.first.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !parent.isEmpty else { return nil }
            return CustomDependentOptionGroup(
                id: pair.id,
                parentValue: parent,
                childOptions: pair.second.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            )
        }
        if let semantic = CustomFieldSemanticRole.allCases.first(where: { $0.displayName == semanticChoice }),
           semanticOptions.contains(semantic.displayName) {
            field.semanticRole = semantic
        }
        if let renderer = compatibleRenderers.first(where: { $0.displayName == rendererChoice }) { field.displayRenderer = renderer }
        if let index = sectionOptions.firstIndex(of: sectionChoice), sections.indices.contains(index) { field.displaySectionID = sections[index].id }
        if conditionChoice == "Always" {
            field.conditionalRule = nil
        } else if let source = selectedConditionField {
            field.conditionalRule = CustomConditionalRule(sourceFieldID: source.id, expectedValue: field.conditionalRule?.expectedValue ?? "")
        }
        onDone()
        dismiss()
    }
}

private struct CustomDisplaySectionEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var section: CustomDisplaySectionDefinition
    @State private var containerChoice = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        HStack {
                            AsteriumPageHeader(eyebrow: "DISPLAY", title: "Edit Section")
                            Spacer()
                            Button { finish() } label: { builderAsset("checkwavy", size: 24) }.buttonStyle(.plain)
                            Button { dismiss() } label: { builderAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
                        }
                        AsteriumTextField(title: "Section Title", placeholder: "Leave blank for no title...", text: $section.title)
                        AsteriumPickerField(title: "Container", options: CustomDisplayContainerKind.allCases.map(\.displayName), selection: $containerChoice)
                        if section.containerKind == .frostedGrid {
                            CustomIntegerStepper(title: "Grid Columns", value: $section.gridColumns, range: 1...3)
                        }
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.never)
                .grimoireFormBackground()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear { containerChoice = section.containerKind.displayName }
        .onChange(of: containerChoice) { _, value in
            if let kind = CustomDisplayContainerKind.allCases.first(where: { $0.displayName == value }) { section.containerKind = kind }
        }
    }

    private func finish() {
        if let kind = CustomDisplayContainerKind.allCases.first(where: { $0.displayName == containerChoice }) { section.containerKind = kind }
        dismiss()
    }
}

private struct CustomPairConfigurationField: View {
    @Binding var pairs: [CustomPairValue]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dependent Options").font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(LColors.textSecondary)
            ForEach($pairs) { $pair in
                VStack(spacing: 8) {
                    AsteriumTextField(title: "Primary Value", placeholder: "Indoor...", text: $pair.first)
                    HStack(alignment: .bottom, spacing: 10) {
                        AsteriumTextField(title: "Dependent Values", placeholder: "Bedroom, Office, Patio...", text: $pair.second)
                        Button { pairs.removeAll { $0.id == pair.id } } label: { builderAsset("trash", size: 17) }.buttonStyle(.plain)
                    }
                }
            }
            Button { pairs.append(CustomPairValue(first: "", second: "")) } label: { builderAsset("addwavy") }.buttonStyle(.plain)
        }
    }
}

private struct CustomIntegerStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .black, design: .rounded)).foregroundStyle(LColors.textSecondary)
            GlassCard(cornerRadius: LSpacing.inputRadius, padding: 12) {
                HStack {
                    Button { value = max(range.lowerBound, value - 1) } label: { builderAsset("minuswavy", size: 17) }.buttonStyle(.plain)
                    Spacer()
                    Text("\(value)").font(.system(size: 16, weight: .black, design: .rounded)).foregroundStyle(LColors.textPrimary)
                    Spacer()
                    Button { value = min(range.upperBound, value + 1) } label: { builderAsset("addwavy", size: 17) }.buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CustomTemplateFormPreview: View {
    @Environment(\.dismiss) private var dismiss
    let schema: CustomGrimoireSchema
    @Binding var values: [UUID: CustomFieldValue]

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        previewHeader(title: "Form Preview", dismiss: dismiss)
                        CustomGrimoireFormFields(schema: schema, values: $values)
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.never)
                .grimoireFormBackground()
            }.toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct CustomTemplateDisplayPreview: View {
    @Environment(\.dismiss) private var dismiss
    let name: String
    let schema: CustomGrimoireSchema
    @Binding var values: [UUID: CustomFieldValue]

    var body: some View {
        ZStack {
            AsteriumBackground().ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    previewHeader(title: "Display Preview", dismiss: dismiss)
                    CustomGrimoireDisplay(schema: schema, values: $values)
                }
                .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 120)
            }
        }
    }
}

private func previewHeader(title: String, dismiss: DismissAction) -> some View {
    HStack {
        AsteriumPageHeader(eyebrow: "CUSTOM GRIMOIRE", title: title)
        Spacer()
        Button { dismiss() } label: { builderAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
    }
}

private func builderAsset(_ name: String, size: CGFloat = 20) -> some View {
    Image(name).renderingMode(.template).resizable().scaledToFit()
        .frame(width: size, height: size).foregroundStyle(LGradients.header).frame(width: 36, height: 36)
}
