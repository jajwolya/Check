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
    var isComplete: Bool = false
    
    init(name: String, isComplete: Bool = false) {
        self.name = name
        self.isComplete = isComplete
    }
}
