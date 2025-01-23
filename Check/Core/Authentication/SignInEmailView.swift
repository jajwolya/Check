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
    //    @Published var error: Error?
    @Published var error: String?
    @Published var emailError: String?
    @Published var passwordError: String?

    func signIn() async throws {
        guard !email.isEmpty else {
            self.emailError = "Please provide an email address."
            return
        }
        
        guard !password.isEmpty else {
            self.passwordError = "Please provide a password."
            return
        }
        
        try await AuthenticationManager.shared
            .signInUser(
                email: email, password: password)
    }

    func signUp() async throws {
        guard !email.isEmpty else {
            self.emailError = "Please provide an email address."
            return
        }

        guard !password.isEmpty else {
            self.passwordError = "Please provide a password."
            return
        }

        guard password.count >= 6 else {
            self.passwordError = "Password must be at least 6 characters long."
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
    var isSignUp: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceBackground.ignoresSafeArea()
                VStack(spacing: Padding.regular) {

                    emailField()

                    if let error = viewModel.emailError {
                        errorMessage(error: error)
                    }

                    CustomSecureField().environmentObject(viewModel)

                    if let error = viewModel.passwordError {
                        errorMessage(error: error)
                    }

                    Button(action: {
                        Task {
                            do {
                                if isSignUp {
                                    try await viewModel.signUp()
                                } else {
                                    try await viewModel.signIn()
                                }
                                showSignInView = false
                            } catch {
                                print("Error: \(error)")
                                withAnimation {
                                    viewModel.error = error.localizedDescription
                                }
                            }
                        }
                    }) {
                        Text(isSignUp ? "Sign up" : "Sign in")
                            .foregroundStyle(Color.surfaceBackground)
                            .fontWeight(.medium)
                            .padding(Padding.regular)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )
                            .background(
                                RoundedRectangle(
                                    cornerRadius: CornerRadius.medium
                                )
                                .fill(Color.light)
                            )
                    }

                    if let error = viewModel.error {
                        errorMessage(error: error)
                    }

                }
                .padding(.horizontal, Padding.gutter)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .padding(.top, 64)
                .navigationBarBackButtonHidden(true)
                .overlay {
                    SignInNavBar(
                        title: isSignUp ? "Sign up" : "Sign in"
                    )
                }
            }
        }
    }

    private func errorMessage(error: String) -> some View {
        Text(error)
            .font(.caption)
            .foregroundStyle(Color.light)
            .multilineTextAlignment(.center)
            .transition(.opacity)
            .animation(
                .easeIn,
                value: error
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emailField() -> some View {
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .padding(Padding.regular)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.regular)
                    .fill(Color.surface)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: CornerRadius.regular
                )
                .stroke(
                    viewModel.emailError != nil
                        ? Color.surfaceLight : Color.clear)
            )
            .onChange(of: viewModel.email) {
                if !viewModel.email.isEmpty {
                    viewModel.emailError = nil
                }
            }
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
