//
//  Sheets.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/1/2025.
//

import Foundation
import SwiftUI

enum SheetType: Identifiable {
    case addingList
    case editingList
    case pendingList
    
    case addingCategory
    case editingCategory
    case addingItem
    case editingItem
    
    case shareList
    case renameList
    case deleteList
    
    case renameCategory
    case deleteCategory
    

    var id: Int {
        hashValue
    }
}

enum SettingsSheetType: Identifiable {
    case updatingDisplayName
    case updatingEmail
    case updatingPassword
    case resettingPassword

    var id: Int {
        hashValue
    }
}

enum ActiveSheet: Identifiable {
    case addingList
    case editingList
    case pendingList

    var id: Int {
        hashValue
    }
}

enum ActiveListSheet: Identifiable {
    case addingCategory
    case editingCategory
    case addingItem
    case editingItem
    
    var id: Int {
        hashValue
    }
}

enum ActiveEditListSheet: Identifiable {
    case shareList
    case renameList
    case deleteList
    
    var id: Int {
        hashValue
    }
}

enum ActiveEditItemSheet {
    case item
    case categories
}
