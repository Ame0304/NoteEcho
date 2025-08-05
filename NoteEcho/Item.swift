//
//  Item.swift
//  NoteEcho
//
//  Created by Vera Ren on 2025-08-05.
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
