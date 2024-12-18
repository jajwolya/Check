//
//  AuthenticationManager.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/12/2024.
//

import FirebaseAuth
import Foundation

struct AuthDataResultModel {
    let uid: String
    let email: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthenticationManager {
    // TODO: replace singleton
    static let shared = AuthenticationManager()
    private init() {
        setupAuthListener()
    }
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    private func setupAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in
                print("User signed in: \(user.uid)")
                // You can also trigger loading user-specific data here if needed
            } else {
                // No user is signed in
                print("No user is signed in.")
            }
        }
    }

    @discardableResult
    func createUser(email: String, password: String) async throws
        -> AuthDataResultModel
    {
        let authDataResult = try await Auth.auth().createUser(
            withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws
        -> AuthDataResultModel
    {
        let authDataResult = try await Auth.auth().signIn(
            withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw UserError.noCurrentUser("Failed to get current user.")
        }
        return AuthDataResultModel(user: user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func updatePasword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }

    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}
