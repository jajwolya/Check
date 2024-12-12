//
//  Item.swift
//  Check
//
//  Created by Jajwol Bajracharya on 11/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var name: String
    var quantity: Int = 1
    var note: String = ""
    var isComplete: Bool = false
    
    init(name: String, quantity: Int = 1, note: String = "", isComplete: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isComplete = isComplete
    }
}
