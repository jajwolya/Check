//
//  Errors.swift
//  Check
//
//  Created by Jajwol Bajracharya on 18/12/2024.
//

import Foundation
import SwiftUI

enum ListError: Error {
    case creationFailed(String)
}

enum UserError: Error {
    case notLoggedIn(String)
    case noCurrentUser(String)
}

enum EncodeError: Error {
    case encodeFailed(String)
}

enum FirestoreError: Error {
    case updateFailed(String)
}
