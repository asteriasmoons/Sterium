//
//  Item.swift
//  Asterium
//
//  Created by Asteria Moon on 7/17/26.
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
