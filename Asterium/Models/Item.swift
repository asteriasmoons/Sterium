//
//  Item.swift
//  Sterium
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date = Date()

    init(timestamp: Date = .now) {
        self.timestamp = timestamp
    }
}
