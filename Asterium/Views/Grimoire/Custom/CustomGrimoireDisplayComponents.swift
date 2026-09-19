//
// CustomGrimoireDisplayComponents.swift
// Sterium
//

import SwiftUI
import SwiftData

struct CustomGrimoireDisplay: View {
    let schema: CustomGrimoireSchema
    @Binding var values: [UUID: CustomFieldValue]
    var allowsInlineEditing = false
    var onValuesChanged: () -> Void = {}

    private var sections: [CustomDisplaySectionDefinition] {
        schema.displaySections.sorted { $0.order < $1.order }
    }

    var body: some View {
        ForEach(sections) { section in
            sectionView(section)
        }
    }

    @ViewBuilder
    private func sectionView(_ section: CustomDisplaySectionDefinition) -> some View {
        let fields = schema.fields
            .filter { $0.displaySectionID == section.id && $0.semanticRole != .entryTitle }
            .sorted { $0.displayOrder < $1.displayOrder }

        if !fields.isEmpty {
            switch section.containerKind {
            case .card, .groupedCard:
                GrimoireDetailSection(title: section.title.isEmpty ? nil : section.title) {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(fields) { field in displayField(field) }
                    }
                }
            case .cardless:
                VStack(alignment: .leading, spacing: 12) {
                    if !section.title.isEmpty { AsteriumSectionHeader(title: section.title) }
                    ForEach(fields) { field in displayField(field) }
                }
            case .frostedGrid:
                GrimoireDetailSection(title: section.title.isEmpty ? nil : section.title) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: max(1, min(section.gridColumns, 3))),
                        spacing: 12
                    ) {
                        ForEach(fields) { field in
                            VStack(alignment: .leading, spacing: 7) {
                                if (field.hidesFieldLabel ?? false) == false { displayLabel(field.label) }
                                displayField(field, showsLabel: false)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func displayField(_ field: CustomFieldDefinition, showsLabel: Bool = true) -> some View {
        let value = values[field.id] ?? .empty(for: field)
        VStack(alignment: .leading, spacing: 8) {
            if showsLabel && (field.hidesFieldLabel ?? false) == false { displayLabel(field.label) }

            switch field.displayRenderer {
            case .plainText:
                plainText(value, field: field)
            case .labelValueRows:
                labelValueRows(value, field: field)
            case .frostedTile:
                frostedTiles(value.stringsForDisplay)
            case .stackedTiles:
                stackedTiles(value.strings)
            case .gradientChips:
                gradientChips(value.stringsForDisplay)
            case .translucentChips:
                translucentChips(value.stringsForDisplay)
            case .statusPill:
                statusPill(formattedText(value, field: field))
            case .gradientNumbers:
                numberedShapes(value.stringsForDisplay, usesCircle: true)
            case .numberedCircles:
                numberedShapes(value.stringsForDisplay, usesCircle: true)
            case .dots:
                dotRating(value.ratingValue, maximum: field.ratingMaximum)
            case .stars:
                starRating(value.ratingValue, maximum: field.ratingMaximum)
            case .numberedList:
                numberedList(value.stringsForDisplay)
            case .gradientBullets:
                gradientBullets(value.stringsForDisplay)
            case .assetIconSteps:
                assetSteps(value.stringsForDisplay)
            case .repeatedPairs:
                repeatedPairs(value)
            case .attachmentGallery:
                attachmentGallery(value.attachments)
            case .relatedEntryCards:
                CustomRelatedEntriesDisplay(references: value.relationships)
            case .inlineEditable:
                if allowsInlineEditing {
                    CustomInlineEditableDisplay(
                        field: field,
                        value: Binding(
                            get: { values[field.id] ?? .empty(for: field) },
                            set: {
                                values[field.id] = $0
                                onValuesChanged()
                            }
                        )
                    )
                } else {
                    plainText(value, field: field)
                }
            }
        }
    }

    private func displayLabel(_ label: String) -> some View {
        Text(label.uppercased())
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(LColors.textSecondary)
    }

    private func plainText(_ value: CustomFieldValue, field: CustomFieldDefinition? = nil) -> some View {
        let text = field.map { formattedText(value, field: $0) } ?? value.displayText
        return Text(text.isEmpty ? "No details" : text)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(text.isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func labelValueRows(_ value: CustomFieldValue, field: CustomFieldDefinition) -> some View {
        let items = field.valueType == .strings ? value.stringsForDisplay : [formattedText(value, field: field)]
        return VStack(alignment: .leading, spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
            }
        }
    }

    private func stackedTiles(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                    .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.16), lineWidth: 1) }
            }
        }
    }

    private func frostedTiles(_ items: [String]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                    .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.16), lineWidth: 1) }
            }
        }
    }

    private func gradientChips(_ items: [String]) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(LGradients.tag.opacity(0.55)))
                    .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
            }
        }
    }

    private func translucentChips(_ items: [String]) -> some View {
        FlowLayout(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                Text(items[index])
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.12), in: Capsule())
                    .overlay { Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1) }
            }
        }
    }

    private func statusPill(_ text: String) -> some View {
        Text(text.isEmpty ? "No status" : text)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(LGradients.tag, in: Capsule())
    }

    private func numberedShapes(_ items: [String], usesCircle: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.bg)
                        .frame(width: 28, height: 28)
                        .background {
                            if usesCircle {
                                Circle().fill(LGradients.tag)
                            } else {
                                RoundedRectangle(cornerRadius: 9).fill(LGradients.tag)
                            }
                        }
                    Text(items[index])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func numberedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1).")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(LGradients.header)
                    Text(items[index])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                }
            }
        }
    }

    private func gradientBullets(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .center, spacing: 12) {
                    Circle().fill(LGradients.tag).frame(width: 11, height: 11)
                    Text(items[index])
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func assetSteps(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(items.prefix(9).enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 10) {
                    Image("\(index + 1)wavy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text(item)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
        }
    }

    private func dotRating(_ rating: Int, maximum: Int) -> some View {
        HStack(spacing: 7) {
            ForEach(1...max(1, maximum), id: \.self) { level in
                Circle()
                    .fill(level <= rating ? AnyShapeStyle(LGradients.tag) : AnyShapeStyle(LColors.glassSurface))
                    .frame(width: 13, height: 13)
                    .overlay { Circle().strokeBorder(level <= rating ? Color.clear : LColors.glassBorder, lineWidth: 1) }
            }
        }
    }

    private func starRating(_ rating: Int, maximum: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...max(1, maximum), id: \.self) { level in
                Image("starfill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(level <= rating ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
            }
        }
    }

    @ViewBuilder
    private func repeatedPairs(_ value: CustomFieldValue) -> some View {
        switch value {
        case let .pairs(pairs):
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(pairs) { pair in
                    VStack(alignment: .leading, spacing: 6) {
                        displayLabel(pair.first.isEmpty ? "Item" : pair.first)
                        Text(pair.second)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1) }
                }
            }
        case let .dependentChoice(selection):
            VStack(alignment: .leading, spacing: 8) {
                plainText(.text(selection.parent))
                plainText(.text(selection.child))
            }
        default:
            plainText(value)
        }
    }

    private func attachmentGallery(_ attachments: [CustomAttachmentReference]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(attachments) { attachment in
                    CustomAttachmentImage(reference: attachment, size: 180)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func formattedText(_ value: CustomFieldValue, field: CustomFieldDefinition) -> String {
        if case let .date(date) = value {
            if field.componentKind == .dateTime {
                return date.formatted(.dateTime.month(.wide).day().year().hour().minute())
            }
            return date.formatted(.dateTime.month(.wide).day().year())
        }
        return value.displayText
    }
}

private struct CustomInlineEditableDisplay: View {
    let field: CustomFieldDefinition
    @Binding var value: CustomFieldValue

    var body: some View {
        switch value {
        case let .text(text):
            AsteriumTextEditor(
                title: "",
                placeholder: field.placeholder.isEmpty ? field.label : field.placeholder,
                text: Binding(get: { text }, set: { value = .text($0) }),
                minHeight: 100
            )
        case let .strings(items):
            CustomExpandableListField(
                title: "",
                placeholder: field.placeholder.isEmpty ? "Add value..." : field.placeholder,
                listTitle: field.label,
                items: Binding(get: { items }, set: { value = .strings($0) }),
                maximumItems: field.maximumItems
            )
        default:
            Text(value.displayText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
        }
    }
}

struct CustomRelatedEntriesDisplay: View {
    let references: [CustomEntryReference]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(references) { reference in
                NavigationLink {
                    CustomRelatedEntryDestination(reference: reference)
                } label: {
                    GlassCard(padding: 0) {
                        HStack(spacing: 14) {
                            Image(reference.iconName)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 32, height: 32)
                                .background(LColors.glassSurface, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reference.title)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                Text(reference.typeName)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                            }
                            Spacer()
                            Image("rightwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(LGradients.header)
                        }
                        .padding(.horizontal, 26)
                        .padding(.vertical, 16)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CustomRelatedEntryDestination: View {
    let reference: CustomEntryReference

    @Query private var journals: [JournalEntry]
    @Query private var experiences: [ExperienceEntry]
    @Query private var workingDocuments: [WorkingDocumentEntry]
    @Query private var workingResults: [WorkingResultEntry]
    @Query private var dreams: [DreamEntry]
    @Query private var synchronicities: [SynchronicityEntry]
    @Query private var pathworks: [PathworkEntry]
    @Query private var moonPhases: [MoonPhaseEntry]
    @Query private var deityDevotions: [DeityDevotionEntry]
    @Query private var divinations: [DivinationEntry]
    @Query private var meditations: [MeditationEntry]
    @Query private var shadowWorks: [ShadowWorkEntry]
    @Query private var manifestations: [ManifestationEntry]
    @Query private var customEntries: [CustomGrimoireEntry]

    var body: some View {
        destination
    }

    @ViewBuilder
    private var destination: some View {
        if reference.targetKindRawValue == "custom" {
            if let entry = customEntries.first(where: { $0.id == reference.targetID }) {
                CustomGrimoireEntryDetail(entry: entry)
            } else { EmptyView() }
        } else if let type = GrimoireEntryType(rawValue: reference.targetKindRawValue) {
            switch type {
            case .journal:
                if let entry = journals.first(where: { $0.id == reference.targetID }) { JournalEntryDetail(entry: entry) }
            case .experience:
                if let entry = experiences.first(where: { $0.id == reference.targetID }) { ExperienceEntryDetail(entry: entry) }
            case .workingDocument:
                if let entry = workingDocuments.first(where: { $0.id == reference.targetID }) { WorkingDocumentEntryDetail(entry: entry) }
            case .workingResult:
                if let entry = workingResults.first(where: { $0.id == reference.targetID }) { WorkingResultEntryDetail(entry: entry) }
            case .dream:
                if let entry = dreams.first(where: { $0.id == reference.targetID }) { DreamEntryDetail(entry: entry) }
            case .synchronicity:
                if let entry = synchronicities.first(where: { $0.id == reference.targetID }) { SynchronicityEntryDetail(entry: entry) }
            case .pathwork:
                if let entry = pathworks.first(where: { $0.id == reference.targetID }) { PathworkEntryDetail(entry: entry) }
            case .moonPhase:
                if let entry = moonPhases.first(where: { $0.id == reference.targetID }) { MoonPhaseEntryDetail(entry: entry) }
            case .deityDevotion:
                if let entry = deityDevotions.first(where: { $0.id == reference.targetID }) { DeityDevotionEntryDetail(entry: entry) }
            case .divination:
                if let entry = divinations.first(where: { $0.id == reference.targetID }) { DivinationEntryDetail(entry: entry) }
            case .meditation:
                if let entry = meditations.first(where: { $0.id == reference.targetID }) { MeditationEntryDetail(entry: entry) }
            case .shadowWork:
                if let entry = shadowWorks.first(where: { $0.id == reference.targetID }) { ShadowWorkEntryDetail(entry: entry) }
            case .manifestation:
                if let entry = manifestations.first(where: { $0.id == reference.targetID }) { ManifestationEntryDetail(entry: entry) }
            }
        } else {
            EmptyView()
        }
    }
}

extension CustomFieldValue {
    var strings: [String] {
        if case let .strings(values) = self { return values }
        return []
    }

    var stringsForDisplay: [String] {
        switch self {
        case let .strings(values):
            let customMarker = "__custom_value__:"
            let custom = values.first(where: { $0.hasPrefix(customMarker) })
                .map { String($0.dropFirst(customMarker.count)) }
            return values
                .filter { !$0.hasPrefix(customMarker) }
                .map { $0 == "Custom" && custom?.isEmpty == false ? custom! : $0 }
        default:
            let text = displayText
            return text.isEmpty ? [] : [text]
        }
    }

    var ratingValue: Int {
        if case let .rating(value) = self { return value }
        return 0
    }

    var attachments: [CustomAttachmentReference] {
        if case let .attachments(values) = self { return values }
        return []
    }

    var relationships: [CustomEntryReference] {
        if case let .relationships(values) = self { return values }
        return []
    }

    var displayText: String {
        switch self {
        case let .text(value): return value
        case let .number(value):
            guard let value else { return "" }
            return value.rounded() == value ? String(Int(value)) : String(value)
        case let .date(value): return value.formatted(date: .long, time: .omitted)
        case let .boolean(value): return value ? "Yes" : "No"
        case .strings: return stringsForDisplay.joined(separator: ", ")
        case let .pairs(values): return values.map { "\($0.first): \($0.second)" }.joined(separator: "\n")
        case let .rating(value): return String(value)
        case let .attachments(values): return "\(values.count) attachment\(values.count == 1 ? "" : "s")"
        case let .relationships(values): return values.map(\.title).joined(separator: ", ")
        case let .dependentChoice(value): return [value.parent, value.child].filter { !$0.isEmpty }.joined(separator: " - ")
        }
    }
}
