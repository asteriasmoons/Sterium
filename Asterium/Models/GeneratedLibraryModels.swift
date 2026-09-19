//
//  GeneratedLibraryModels.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class SavedCorrespondenceRecord {
    var id: UUID = UUID()
    var type: String = ""
    var name: String = ""
    var source: String = ""
    var updatedAt: String = ""
    var payload: Data = Data()

    init(type: String, name: String, source: String, updatedAt: String, payload: Data) {
        self.type = type
        self.name = name
        self.source = source
        self.updatedAt = updatedAt
        self.payload = payload
    }
}

@Model
final class SavedSpellRecord {
    var id: UUID = UUID()
    var category: String = ""
    var intention: String = ""
    var title: String = ""
    var source: String = ""
    var updatedAt: String = ""
    var payload: Data = Data()

    init(category: String, intention: String, title: String, source: String, updatedAt: String, payload: Data) {
        self.category = category
        self.intention = intention
        self.title = title
        self.source = source
        self.updatedAt = updatedAt
        self.payload = payload
    }
}
