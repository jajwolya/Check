//
//  SettingsViewModel.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import Foundation

@MainActor final class SettingsViewModel: ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    func resetPassword() async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = user.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }

    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePasword(password: password)
    }
}
