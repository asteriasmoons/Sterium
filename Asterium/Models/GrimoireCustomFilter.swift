//
//  GrimoireCustomFilter.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class GrimoireCustomFilter {
    var id: UUID = UUID()
    var name: String = ""
    var typeRawValues: [String] = []
    var createdAt: Date = Date()

    init(name: String, typeRawValues: [String]) {
        self.name = name
        self.typeRawValues = typeRawValues
        self.createdAt = Date()
    }

    var entryTypes: [GrimoireEntryType] {
        typeRawValues.compactMap { GrimoireEntryType(rawValue: $0) }
    }
}
