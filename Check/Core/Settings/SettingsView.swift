//
//  SettingsView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        Settings
    }
}

extension SettingsView {
    private var Settings: some View {
        List {
            Section("Email") {
                Button(action: { handleUpdateEmail() }) {
                    Text("Update email")
                }
            }
            Section("Password") {
                Button(action: { handleUpdatePassword() }) {
                    Text("Update password")
                }
                Button(action: { handleResetPassword() }) {
                    Text("Reset password")
                }
            }
            Button(action: { handleLogOut() }) {
                Text("Log out")
            }
        }.navigationTitle("Settings")
    }
    
    private func handleUpdatePassword() {
        Task {
            do {
                let password = "newPassword"
                try await viewModel.updatePassword(password: password)
            } catch {
                print(error)
            }
        }
    }

    private func handleUpdateEmail() {
        Task {
            do {
                let email = "new@test.com"
                try await viewModel.updateEmail(email: email)
            } catch {
                print(error)
            }
        }
    }

    private func handleLogOut() {
        Task {
            do {
                try viewModel.signOut()
                showSignInView = true
            } catch {
                print(error)
            }
        }
    }

    private func handleResetPassword() {
        Task {
            do {
                try await viewModel.resetPassword()
                showSignInView = true
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}
