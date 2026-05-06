//
//  Item.swift
//  Carelens-Aged+
//
//  Created by Christopher Appiah-Thompson  on 7/5/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
