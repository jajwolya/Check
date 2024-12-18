//
//  SignInEmailView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/12/2024.
//

import SwiftUI

@MainActor final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Please ensure both email and password are filled.")
            return
        }
        try await AuthenticationManager.shared
            .signInUser(
                email: email, password: password)
    }

    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Please ensure both email and password are filled.")
            return
        }
        let authDataResult = try await AuthenticationManager.shared
            .createUser(
                email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
}

struct SignInEmailView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel: SignInEmailViewModel =
        SignInEmailViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        }

//                        do {
//                            try await viewModel.signIn()
//                            showSignInView = false
//                            return
//                        } catch {
//                            print("Error signing in: \(error)")
//                        }
                    }
                }) {
                    Text("Sign in")
                }
            }.navigationTitle("Sign in")
        }
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
