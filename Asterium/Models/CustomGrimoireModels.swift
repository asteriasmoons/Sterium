//
// CustomGrimoireModels.swift
// Sterium
//

import Foundation
import SwiftData

enum CustomFieldValueType: String, Codable, CaseIterable {
    case text
    case number
    case date
    case boolean
    case strings
    case pairs
    case rating
    case attachments
    case relationships
    case dependentChoice
}

enum CustomFormComponentKind: String, Codable, CaseIterable, Identifiable {
    case shortText
    case paragraph
    case number
    case date
    case dateTime
    case singleSelect
    case multiSelect
    case createToAddList
    case freeEntryValues
    case repeatableList
    case repeatableGroup
    case repeatedPairs
    case dynamicSteps
    case numberRating
    case dotRating
    case starRating
    case yesNo
    case conditionalText
    case dependentSelector
    case attachments
    case relatedEntries
    case relationshipSelector
    case inlineEditableList
    case importance
    case tags

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .shortText: return "Short Text"
        case .paragraph: return "Paragraph"
        case .number: return "Number"
        case .date: return "Date"
        case .dateTime: return "Date & Time"
        case .singleSelect: return "Single-Select Dropdown"
        case .multiSelect: return "Multi-Select Dropdown"
        case .createToAddList: return "Create-to-Add List"
        case .freeEntryValues: return "Free-Entry Values"
        case .repeatableList: return "Repeatable List"
        case .repeatableGroup: return "Repeatable Group"
        case .repeatedPairs: return "Repeated Pairs"
        case .dynamicSteps: return "Numbered Steps"
        case .numberRating: return "Number Rating"
        case .dotRating: return "Dot Rating"
        case .starRating: return "Star Rating"
        case .yesNo: return "Yes / No"
        case .conditionalText: return "Conditional Text"
        case .dependentSelector: return "Dependent Selector"
        case .attachments: return "Attachments"
        case .relatedEntries: return "Related Entries"
        case .relationshipSelector: return "Relationship Selector"
        case .inlineEditableList: return "Inline Editable List"
        case .importance: return "Importance"
        case .tags: return "Tags"
        }
    }

    var iconName: String {
        switch self {
        case .shortText: return "linespencil"
        case .paragraph: return "linedpages"
        case .number: return "hashtagwavy"
        case .date, .dateTime: return "blackcal"
        case .singleSelect, .multiSelect: return "chevdown"
        case .createToAddList, .repeatableList, .inlineEditableList: return "lovelist"
        case .freeEntryValues, .tags: return "tagstar"
        case .repeatableGroup, .repeatedPairs: return "threeboxes"
        case .dynamicSteps: return "listcircle"
        case .numberRating, .dotRating, .importance: return "dotswavy"
        case .starRating: return "starfill"
        case .yesNo, .conditionalText: return "checkwavy"
        case .dependentSelector: return "arrowscircle"
        case .attachments: return "imagesign"
        case .relatedEntries, .relationshipSelector: return "linkcircle"
        }
    }

    var valueType: CustomFieldValueType {
        switch self {
        case .shortText, .paragraph, .conditionalText: return .text
        case .number: return .number
        case .date, .dateTime: return .date
        case .singleSelect, .multiSelect: return .strings
        case .createToAddList, .freeEntryValues, .repeatableList, .dynamicSteps,
             .inlineEditableList, .tags: return .strings
        case .repeatableGroup, .repeatedPairs: return .pairs
        case .numberRating, .dotRating, .starRating, .importance: return .rating
        case .yesNo: return .boolean
        case .dependentSelector: return .dependentChoice
        case .attachments: return .attachments
        case .relatedEntries, .relationshipSelector: return .relationships
        }
    }
}

enum CustomDisplayRendererKind: String, Codable, CaseIterable, Identifiable {
    case plainText
    case labelValueRows
    case frostedTile
    case stackedTiles
    case gradientChips
    case translucentChips
    case statusPill
    case gradientNumbers
    case numberedCircles
    case dots
    case stars
    case numberedList
    case gradientBullets
    case assetIconSteps
    case repeatedPairs
    case attachmentGallery
    case relatedEntryCards
    case inlineEditable

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .plainText: return "Plain Text"
        case .labelValueRows: return "Label / Value Row"
        case .frostedTile: return "Frosted Tile"
        case .stackedTiles: return "Stacked Translucent Tiles"
        case .gradientChips: return "Gradient Chips"
        case .translucentChips: return "Translucent Chips"
        case .statusPill: return "Status Pill"
        case .gradientNumbers: return "Gradient Numbers"
        case .numberedCircles: return "Numbered Circles"
        case .dots: return "Dots"
        case .stars: return "Stars"
        case .numberedList: return "Numbered List"
        case .gradientBullets: return "Gradient Bullets"
        case .assetIconSteps: return "Asset-Icon Steps"
        case .repeatedPairs: return "Repeated Pairs"
        case .attachmentGallery: return "Attachment Gallery"
        case .relatedEntryCards: return "Related Entry Cards"
        case .inlineEditable: return "Inline Editable"
        }
    }

    func accepts(_ valueType: CustomFieldValueType) -> Bool {
        switch self {
        case .plainText, .labelValueRows, .frostedTile:
            return [.text, .number, .date, .boolean, .strings, .dependentChoice].contains(valueType)
        case .stackedTiles, .gradientChips, .translucentChips, .gradientNumbers,
             .numberedCircles, .numberedList, .gradientBullets, .assetIconSteps:
            return valueType == .strings
        case .statusPill:
            return [.text, .boolean, .strings].contains(valueType)
        case .dots, .stars:
            return valueType == .rating
        case .repeatedPairs:
            return valueType == .pairs || valueType == .dependentChoice
        case .attachmentGallery:
            return valueType == .attachments
        case .relatedEntryCards:
            return valueType == .relationships
        case .inlineEditable:
            return [.text, .strings].contains(valueType)
        }
    }

    static func compatible(with valueType: CustomFieldValueType) -> [CustomDisplayRendererKind] {
        allCases.filter { $0.accepts(valueType) }
    }
}

enum CustomDisplayContainerKind: String, Codable, CaseIterable, Identifiable {
    case card
    case cardless
    case frostedGrid
    case groupedCard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .card: return "Card"
        case .cardless: return "Cardless"
        case .frostedGrid: return "Frosted Tile Grid"
        case .groupedCard: return "Grouped Card"
        }
    }
}

enum CustomFieldSemanticRole: String, Codable, CaseIterable, Identifiable {
    case none
    case entryTitle
    case entryDate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .entryTitle: return "Entry Title"
        case .entryDate: return "Entry Date"
        }
    }
}

struct CustomConditionalRule: Codable, Equatable {
    var sourceFieldID: UUID
    var expectedValue: String
}

struct CustomDependentOptionGroup: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var parentValue: String
    var childOptions: [String]
}

struct CustomFieldDefinition: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var label: String
    var placeholder: String
    var componentKind: CustomFormComponentKind
    var isRequired = false
    var options: [String] = []
    var allowsCustomValue = false
    var customValueLabel = "Custom"
    var maximumItems = 20
    var ratingMaximum = 5
    var pairFirstLabel = "Label"
    var pairSecondLabel = "Description"
    var pairFirstOptions: [String] = []
    var dependentGroups: [CustomDependentOptionGroup] = []
    var conditionalRule: CustomConditionalRule?
    var semanticRole: CustomFieldSemanticRole = .none
    var displaySectionID: UUID
    var displayRenderer: CustomDisplayRendererKind
    var displayOrder: Int
    var hidesFieldLabel: Bool? = nil

    var valueType: CustomFieldValueType { componentKind.valueType }
}

struct CustomDisplaySectionDefinition: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var containerKind: CustomDisplayContainerKind = .card
    var order: Int
    var gridColumns: Int = 2
}

struct CustomGrimoireSchema: Codable, Equatable {
    var fields: [CustomFieldDefinition]
    var displaySections: [CustomDisplaySectionDefinition]

    static func starter() -> CustomGrimoireSchema {
        let section = CustomDisplaySectionDefinition(title: "Details", order: 0)
        return CustomGrimoireSchema(
            fields: [
                CustomFieldDefinition(
                    label: "Title",
                    placeholder: "Entry title...",
                    componentKind: .shortText,
                    semanticRole: .entryTitle,
                    displaySectionID: section.id,
                    displayRenderer: .plainText,
                    displayOrder: 0
                ),
                CustomFieldDefinition(
                    label: "Date",
                    placeholder: "",
                    componentKind: .date,
                    semanticRole: .entryDate,
                    displaySectionID: section.id,
                    displayRenderer: .plainText,
                    displayOrder: 1
                )
            ],
            displaySections: [section]
        )
    }
}

struct CustomPairValue: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var first: String
    var second: String
}

struct CustomDependentValue: Codable, Equatable {
    var parent: String = ""
    var child: String = ""
}

struct CustomAttachmentReference: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var displayName: String
    var relativePath: String
    var kind: String = "photo"
}

struct CustomEntryReference: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var targetID: UUID
    var targetKindRawValue: String
    var title: String
    var typeName: String
    var iconName: String
}

enum CustomFieldValue: Codable, Equatable {
    case text(String)
    case number(Double?)
    case date(Date)
    case boolean(Bool)
    case strings([String])
    case pairs([CustomPairValue])
    case rating(Int)
    case attachments([CustomAttachmentReference])
    case relationships([CustomEntryReference])
    case dependentChoice(CustomDependentValue)

    static func empty(for field: CustomFieldDefinition) -> CustomFieldValue {
        switch field.valueType {
        case .text: return .text("")
        case .number: return .number(nil)
        case .date: return .date(.now)
        case .boolean: return .boolean(false)
        case .strings: return .strings([])
        case .pairs: return .pairs([])
        case .rating: return .rating(0)
        case .attachments: return .attachments([])
        case .relationships: return .relationships([])
        case .dependentChoice: return .dependentChoice(CustomDependentValue())
        }
    }
}

struct CustomStoredFieldValue: Codable, Equatable, Identifiable {
    var fieldID: UUID
    var value: CustomFieldValue
    var id: UUID { fieldID }
}

enum CustomGrimoireCoding {
    static func encodeSchema(_ schema: CustomGrimoireSchema) -> Data {
        (try? JSONEncoder().encode(schema)) ?? Data()
    }

    static func decodeSchema(_ data: Data) -> CustomGrimoireSchema {
        (try? JSONDecoder().decode(CustomGrimoireSchema.self, from: data)) ?? .starter()
    }

    static func encodeValues(_ values: [UUID: CustomFieldValue]) -> Data {
        let records = values.map { CustomStoredFieldValue(fieldID: $0.key, value: $0.value) }
        return (try? JSONEncoder().encode(records)) ?? Data()
    }

    static func decodeValues(_ data: Data) -> [UUID: CustomFieldValue] {
        guard let records = try? JSONDecoder().decode([CustomStoredFieldValue].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: records.map { ($0.fieldID, $0.value) })
    }
}

@Model
final class CustomGrimoireTemplate {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = "grimoire"
    var currentVersion: Int = 1
    var currentSchemaData: Data = Data()
    var isArchived: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        currentVersion: Int,
        currentSchemaData: Data,
        isArchived: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.currentVersion = currentVersion
        self.currentSchemaData = currentSchemaData
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class CustomGrimoireTemplateVersion {
    var id: UUID = UUID()
    var templateID: UUID = UUID()
    var version: Int = 1
    var name: String = ""
    var iconName: String = "grimoire"
    var schemaData: Data = Data()
    var createdAt: Date = Date()

    init(templateID: UUID, version: Int, name: String, iconName: String, schemaData: Data) {
        self.templateID = templateID
        self.version = version
        self.name = name
        self.iconName = iconName
        self.schemaData = schemaData
    }
}

@Model
final class CustomGrimoireEntry {
    var id: UUID = UUID()
    var templateID: UUID = UUID()
    var templateVersion: Int = 1
    var templateName: String = ""
    var templateIconName: String = "grimoire"
    var title: String = ""
    var entryDate: Date = Date()
    var schemaSnapshotData: Data = Data()
    var valuesData: Data = Data()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        templateID: UUID,
        templateVersion: Int,
        templateName: String,
        templateIconName: String,
        title: String,
        entryDate: Date,
        schemaSnapshotData: Data,
        valuesData: Data,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.templateID = templateID
        self.templateVersion = templateVersion
        self.templateName = templateName
        self.templateIconName = templateIconName
        self.title = title
        self.entryDate = entryDate
        self.schemaSnapshotData = schemaSnapshotData
        self.valuesData = valuesData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
