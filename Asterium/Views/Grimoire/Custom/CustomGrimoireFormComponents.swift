//
// CustomGrimoireFormComponents.swift
// Sterium
//

import SwiftUI
import SwiftData
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct CustomGrimoireFormFields: View {
    let schema: CustomGrimoireSchema
    @Binding var values: [UUID: CustomFieldValue]

    var body: some View {
        ForEach(schema.fields) { field in
            if isVisible(field) {
                CustomGrimoireFieldInput(field: field, values: $values)
            }
        }
    }

    private func isVisible(_ field: CustomFieldDefinition) -> Bool {
        guard let rule = field.conditionalRule,
              let sourceValue = values[rule.sourceFieldID] else {
            return field.conditionalRule == nil
        }

        return sourceValue.matches(rule.expectedValue)
    }
}

private struct CustomGrimoireFieldInput: View {
    let field: CustomFieldDefinition
    @Binding var values: [UUID: CustomFieldValue]

    var body: some View {
        switch field.componentKind {
        case .shortText, .conditionalText:
            AsteriumTextField(title: field.label, placeholder: placeholder, text: textBinding)
        case .paragraph:
            AsteriumTextEditor(title: field.label, placeholder: placeholder, text: textBinding)
        case .number:
            CustomNumberField(title: field.label, placeholder: placeholder, value: numberBinding)
        case .date:
            AsteriumDateField(title: field.label, date: dateBinding)
        case .dateTime:
            AsteriumDateField(title: field.label, date: dateBinding, includesTime: true)
        case .singleSelect:
            CustomChoiceField(field: field, values: $values, allowsMultiple: false)
        case .multiSelect:
            CustomChoiceField(field: field, values: $values, allowsMultiple: true)
        case .createToAddList, .inlineEditableList:
            CustomExpandableListField(
                title: field.label,
                placeholder: placeholder,
                listTitle: field.label,
                items: stringsBinding,
                maximumItems: field.maximumItems
            )
        case .freeEntryValues, .tags:
            GrimoireChipInput(title: field.label, placeholder: placeholder, items: stringsBinding)
        case .repeatableList:
            CustomDynamicTextListField(
                title: field.label,
                placeholder: placeholder,
                items: stringsBinding,
                maximumItems: field.maximumItems,
                usesNumbers: false
            )
        case .dynamicSteps:
            CustomDynamicTextListField(
                title: field.label,
                placeholder: placeholder,
                items: stringsBinding,
                maximumItems: min(field.maximumItems, 9),
                usesNumbers: true
            )
        case .repeatableGroup, .repeatedPairs:
            CustomPairListField(field: field, pairs: pairsBinding)
        case .numberRating:
            CustomRatingField(title: field.label, rating: ratingBinding, maximum: field.ratingMaximum, style: .numbers)
        case .dotRating, .importance:
            CustomRatingField(title: field.label, rating: ratingBinding, maximum: field.ratingMaximum, style: .dots)
        case .starRating:
            CustomRatingField(title: field.label, rating: ratingBinding, maximum: field.ratingMaximum, style: .stars)
        case .yesNo:
            CustomYesNoField(title: field.label, value: booleanBinding)
        case .dependentSelector:
            CustomDependentSelectorField(field: field, selection: dependentBinding)
        case .attachments:
            CustomAttachmentInput(title: field.label, attachments: attachmentsBinding)
        case .relatedEntries:
            CustomRelatedEntriesInput(title: field.label, references: relationshipsBinding, allowsMultiple: true)
        case .relationshipSelector:
            CustomRelatedEntriesInput(title: field.label, references: relationshipsBinding, allowsMultiple: false)
        }
    }

    private var placeholder: String {
        field.placeholder.isEmpty ? field.label : field.placeholder
    }

    private var textBinding: Binding<String> {
        Binding(
            get: {
                if case let .text(value) = values[field.id] { return value }
                return ""
            },
            set: { values[field.id] = .text($0) }
        )
    }

    private var numberBinding: Binding<Double?> {
        Binding(
            get: {
                if case let .number(value) = values[field.id] { return value }
                return nil
            },
            set: { values[field.id] = .number($0) }
        )
    }

    private var dateBinding: Binding<Date> {
        Binding(
            get: {
                if case let .date(value) = values[field.id] { return value }
                return .now
            },
            set: { values[field.id] = .date($0) }
        )
    }

    private var booleanBinding: Binding<Bool> {
        Binding(
            get: {
                if case let .boolean(value) = values[field.id] { return value }
                return false
            },
            set: { values[field.id] = .boolean($0) }
        )
    }

    private var stringsBinding: Binding<[String]> {
        Binding(
            get: {
                if case let .strings(value) = values[field.id] { return value }
                return []
            },
            set: { values[field.id] = .strings($0) }
        )
    }

    private var pairsBinding: Binding<[CustomPairValue]> {
        Binding(
            get: {
                if case let .pairs(value) = values[field.id] { return value }
                return []
            },
            set: { values[field.id] = .pairs($0) }
        )
    }

    private var ratingBinding: Binding<Int> {
        Binding(
            get: {
                if case let .rating(value) = values[field.id] { return value }
                return 0
            },
            set: { values[field.id] = .rating($0) }
        )
    }

    private var attachmentsBinding: Binding<[CustomAttachmentReference]> {
        Binding(
            get: {
                if case let .attachments(value) = values[field.id] { return value }
                return []
            },
            set: { values[field.id] = .attachments($0) }
        )
    }

    private var relationshipsBinding: Binding<[CustomEntryReference]> {
        Binding(
            get: {
                if case let .relationships(value) = values[field.id] { return value }
                return []
            },
            set: { values[field.id] = .relationships($0) }
        )
    }

    private var dependentBinding: Binding<CustomDependentValue> {
        Binding(
            get: {
                if case let .dependentChoice(value) = values[field.id] { return value }
                return CustomDependentValue()
            },
            set: { values[field.id] = .dependentChoice($0) }
        )
    }
}

private struct CustomNumberField: View {
    let title: String
    let placeholder: String
    @Binding var value: Double?

    private var text: Binding<String> {
        Binding(
            get: {
                guard let value else { return "" }
                return value.rounded() == value ? String(Int(value)) : String(value)
            },
            set: { value = Double($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)
            GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                TextField(placeholder, text: text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(14)
            }
        }
    }
}

private struct CustomChoiceField: View {
    let field: CustomFieldDefinition
    @Binding var values: [UUID: CustomFieldValue]
    let allowsMultiple: Bool

    private var stored: [String] {
        if case let .strings(value) = values[field.id] { return value }
        return []
    }

    private var customMarker: String { "__custom_value__:" }

    private var customValue: Binding<String> {
        Binding(
            get: {
                stored.first(where: { $0.hasPrefix(customMarker) })
                    .map { String($0.dropFirst(customMarker.count)) } ?? ""
            },
            set: { newValue in
                var updated = stored.filter { !$0.hasPrefix(customMarker) }
                if !newValue.isEmpty { updated.append(customMarker + newValue) }
                values[field.id] = .strings(updated)
            }
        )
    }

    private var optionList: [String] {
        guard field.allowsCustomValue, !field.options.contains(field.customValueLabel) else { return field.options }
        return field.options + [field.customValueLabel]
    }

    private var singleSelection: Binding<String> {
        Binding(
            get: { stored.first(where: { optionList.contains($0) }) ?? "" },
            set: { selection in
                let custom = stored.first(where: { $0.hasPrefix(customMarker) })
                values[field.id] = .strings([selection] + (custom.map { [$0] } ?? []))
            }
        )
    }

    private var multipleSelections: Binding<Set<String>> {
        Binding(
            get: { Set(stored.filter { optionList.contains($0) }) },
            set: { selections in
                var updated = optionList.filter { selections.contains($0) }
                if let custom = stored.first(where: { $0.hasPrefix(customMarker) }) { updated.append(custom) }
                values[field.id] = .strings(updated)
            }
        )
    }

    private var showsCustomField: Bool {
        stored.contains(field.customValueLabel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if allowsMultiple {
                AsteriumMultiSelectPickerField(title: field.label, options: optionList, selections: multipleSelections)
            } else {
                AsteriumPickerField(title: field.label, options: optionList, selection: singleSelection)
            }

            if field.allowsCustomValue && showsCustomField {
                AsteriumTextField(
                    title: field.customValueLabel,
                    placeholder: "Enter custom value...",
                    text: customValue
                )
            }
        }
    }
}

struct CustomExpandableListField: View {
    let title: String
    let placeholder: String
    let listTitle: String
    @Binding var items: [String]
    var maximumItems = 20
    @State private var draft = ""
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            HStack(spacing: 10) {
                customShortInput(placeholder, text: $draft)
                    .onSubmit(addItem)
                customAddButton(action: addItem)
            }

            if !items.isEmpty {
                GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { isExpanded.toggle() }
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
                                    customRemoveButton { items.remove(at: index) }
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
        guard !value.isEmpty, items.count < maximumItems else { return }
        items.append(value)
        draft = ""
    }
}

private struct CustomDynamicTextListField: View {
    let title: String
    let placeholder: String
    @Binding var items: [String]
    let maximumItems: Int
    let usesNumbers: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            ForEach(items.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    if usesNumbers {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)
                            .frame(width: 28, height: 28)
                            .background(LGradients.header, in: Circle())
                    }

                    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
                        TextField(placeholder, text: $items[index], axis: .vertical)
                            .lineLimit(1...4)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .padding(14)
                    }

                    customRemoveButton { items.remove(at: index) }
                }
            }

            if items.count < maximumItems {
                customAddButton { items.append("") }
            }
        }
    }
}

private struct CustomPairListField: View {
    let field: CustomFieldDefinition
    @Binding var pairs: [CustomPairValue]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            customFieldLabel(field.label)

            ForEach($pairs) { $pair in
                VStack(alignment: .leading, spacing: 8) {
                    if field.pairFirstOptions.isEmpty {
                        customShortInput(field.pairFirstLabel, text: $pair.first)
                    } else {
                        AsteriumPickerField(title: field.pairFirstLabel, options: field.pairFirstOptions, selection: $pair.first)
                    }

                    HStack(spacing: 10) {
                        customShortInput(field.pairSecondLabel, text: $pair.second)
                        customRemoveButton { pairs.removeAll { $0.id == pair.id } }
                    }
                }
            }

            customAddButton {
                guard pairs.count < field.maximumItems else { return }
                pairs.append(CustomPairValue(first: "", second: ""))
            }
        }
    }
}

private enum CustomRatingStyle {
    case numbers
    case dots
    case stars
}

private struct CustomRatingField: View {
    let title: String
    @Binding var rating: Int
    let maximum: Int
    let style: CustomRatingStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)
            HStack(spacing: 10) {
                ForEach(1...max(1, maximum), id: \.self) { level in
                    Button {
                        rating = rating == level ? max(0, level - 1) : level
                    } label: {
                        switch style {
                        case .numbers:
                            Text("\(level)")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(level <= rating ? LColors.bg : LColors.textSecondary)
                                .frame(width: 40, height: 40)
                                .background(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface), in: Circle())
                        case .dots:
                            Circle()
                                .fill(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                .frame(width: 16, height: 16)
                                .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: level <= rating ? 0 : 1) }
                        case .stars:
                            Image("starfill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundStyle(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CustomYesNoField: View {
    let title: String
    @Binding var value: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)
            HStack(spacing: 10) {
                selectionButton("Yes", selected: value) { value = true }
                selectionButton("No", selected: !value) { value = false }
            }
        }
    }

    private func selectionButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(selected ? LColors.bg : LColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface), in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay { RoundedRectangle(cornerRadius: LSpacing.inputRadius).strokeBorder(selected ? Color.clear : LColors.glassBorder, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }
}

private struct CustomDependentSelectorField: View {
    let field: CustomFieldDefinition
    @Binding var selection: CustomDependentValue

    private var parentOptions: [String] { field.dependentGroups.map(\.parentValue) }
    private var childOptions: [String] {
        field.dependentGroups.first(where: { $0.parentValue == selection.parent })?.childOptions ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumPickerField(
                title: field.label,
                options: parentOptions,
                selection: Binding(
                    get: { selection.parent },
                    set: {
                        selection.parent = $0
                        if !childOptions.contains(selection.child) { selection.child = "" }
                    }
                )
            )

            if !selection.parent.isEmpty {
                AsteriumPickerField(
                    title: selection.parent,
                    options: childOptions,
                    selection: Binding(get: { selection.child }, set: { selection.child = $0 })
                )
            }
        }
    }
}

struct CustomAttachmentInput: View {
    let title: String
    @Binding var attachments: [CustomAttachmentReference]
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customFieldLabel(title)

            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(attachments) { attachment in
                            ZStack(alignment: .topTrailing) {
                                CustomAttachmentImage(reference: attachment, size: 72)
                                Button { remove(attachment) } label: {
                                    Image("xmarkwavy")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(LGradients.header)
                                        .frame(width: 24, height: 24)
                                        .background(LColors.glassSurface2, in: Circle())
                                }
                                .buttonStyle(.plain)
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }

            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack(spacing: 10) {
                    Image("grimoire")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Add Attachment")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(LColors.textPrimary)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay { RoundedRectangle(cornerRadius: LSpacing.inputRadius).strokeBorder(LColors.glassBorder, lineWidth: 1) }
            }
            .buttonStyle(.plain)
            .onChange(of: selectedItem) { _, item in
                guard let item else { return }
                Task {
                    await load(item)
                    selectedItem = nil
                }
            }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        #if canImport(UIKit)
        guard let image = UIImage(data: data), let imageData = image.jpegData(compressionQuality: 0.9) else { return }
        #else
        let imageData = data
        #endif
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let name = "custom_\(UUID().uuidString.prefix(8)).jpg"
        let relativePath = "attachments/\(name)"
        let directory = documents.appendingPathComponent("attachments", isDirectory: true)
        let url = documents.appendingPathComponent(relativePath)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try imageData.write(to: url, options: .atomic)
            attachments.append(CustomAttachmentReference(displayName: name, relativePath: relativePath))
        } catch { return }
    }

    private func remove(_ attachment: CustomAttachmentReference) {
        attachments.removeAll { $0.id == attachment.id }
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? FileManager.default.removeItem(at: documents.appendingPathComponent(attachment.relativePath))
        }
    }
}

struct CustomAttachmentImage: View {
    let reference: CustomAttachmentReference
    var size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: LSpacing.inputRadius).fill(LColors.glassSurface2)
            #if canImport(UIKit)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: LSpacing.inputRadius))
            } else {
                placeholder
            }
            #else
            placeholder
            #endif
        }
        .frame(width: size, height: size)
        .overlay { RoundedRectangle(cornerRadius: LSpacing.inputRadius).strokeBorder(LColors.glassBorder, lineWidth: 1) }
    }

    private var placeholder: some View {
        Image("grimoire")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 22, height: 22)
            .foregroundStyle(LColors.textSecondary)
    }

    #if canImport(UIKit)
    private var image: UIImage? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return UIImage(contentsOfFile: documents.appendingPathComponent(reference.relativePath).path)
    }
    #endif
}

private func customFieldLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 13, weight: .black, design: .rounded))
        .foregroundStyle(LColors.textSecondary)
}

private func customShortInput(_ placeholder: String, text: Binding<String>) -> some View {
    GlassCard(cornerRadius: LSpacing.inputRadius, padding: 0) {
        TextField(placeholder, text: text)
            .lineLimit(1)
            .submitLabel(.done)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .padding(14)
    }
}

private func customAddButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image("addwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(LGradients.header)
            .frame(width: 44, height: 44)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
    }
    .buttonStyle(.plain)
}

private func customRemoveButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image("xmarkwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(LGradients.header)
            .frame(width: 40, height: 40)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(LColors.glassBorder, lineWidth: 1) }
    }
    .buttonStyle(.plain)
}

extension CustomFieldValue {
    fileprivate func matches(_ expectedValue: String) -> Bool {
        switch self {
        case let .text(value): return value == expectedValue
        case let .boolean(value): return expectedValue.lowercased() == (value ? "yes" : "no") || expectedValue == String(value)
        case let .strings(values): return values.contains(expectedValue)
        case let .number(value): return value.map { String($0) } == expectedValue
        case let .rating(value): return String(value) == expectedValue
        case let .dependentChoice(value): return value.parent == expectedValue || value.child == expectedValue
        default: return false
        }
    }
}
