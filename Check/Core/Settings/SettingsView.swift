//
//  SettingsView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/12/2024.
//

import SwiftUI

@MainActor final class SettingsViewModel: ObservableObject {
    @Published private(set) var authUser: AuthDataResultModel?
    @Published private(set) var dbUser: DBUser?

    func setUser() async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        self.authUser = user
        self.dbUser = try await UserManager.shared.getUser(userId: user.uid)
        print(dbUser)
    }

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

    func updateDisplayName(newDisplayName: String) async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        try await UserManager.shared.updateDisplayName(
            userId: user.uid, newDisplayName: newDisplayName)
    }

    func updateEmail(newEmail: String, currentPassword: String) async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        try await AuthenticationManager.shared.updateEmail(
            newEmail: newEmail, currentPassword: currentPassword)

        try await UserManager.shared.updateUserEmail(
            userId: user.uid, newEmail: newEmail)
    }

    func updatePassword(newPassword: String, currentPassword: String)
        async throws
    {
        try await AuthenticationManager.shared
            .updatePassword(
                newPassword: newPassword,
                currentPassword: currentPassword
            )
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State var activeSheet: SettingsSheetType?

    var body: some View {
        Settings

    }
}

extension SettingsView {
    private var Settings: some View {
        List {
            SettingsButton(
                text: "Change display name", icon: "person.crop.circle",
                action: {
                    Task {
                        do {
                            try await viewModel.setUser()
                        }
                    }
                    activeSheet = .updatingDisplayName
                })
            SettingsButton(
                text: "Update email", icon: "at",
                action: { activeSheet = .updatingEmail })
            SettingsButton(
                text: "Update password", icon: "lock.circle.dotted",
                action: { activeSheet = .updatingPassword })
            SettingsButton(
                text: "Reset password", icon: "lock.rotation",
                action: { activeSheet = .resettingPassword })
            SettingsButton(
                text: "Log out", icon: "door.right.hand.open",
                action: { handleLogOut() })
        }
        .padding(.top, 48)
        .listSectionSpacing(.compact)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(.insetGrouped)
        .foregroundStyle(Color.content)
        .background(Color.surfaceBackground)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)
        .overlay {
            SettingsNavBar(
                title: "Settings"
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .updatingDisplayName:
                UpdateDisplayNameSheet(
                    dismissAction: { activeSheet = nil }
                ).environmentObject(viewModel)

            case .updatingEmail:
                UpdateEmailSheet(
                    dismissAction: { activeSheet = nil }
                ).environmentObject(viewModel)

            case .updatingPassword:
                UpdatePasswordSheet(
                    dismissAction: { activeSheet = nil }
                ).environmentObject(viewModel)

            case .resettingPassword:
                ConfirmSheet(
                    heading: "Reset password",
                    text:
                        "Are you sure you want to reset your password?",
                    caption: "An email will be sent to your registered email address to reset your password.",
                    dismissAction: { activeSheet = nil },
                    confirmAction: {
                        handleResetPassword()
                        activeSheet = nil
                    }
                )
            }
        }
    }

    private func SettingsButton(
        text: String, icon: String, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text("\(text)")
                Spacer()
                Image(systemName: icon).foregroundStyle(Color.surfaceLight)
            }.padding(.vertical, Padding.small)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(
            RoundedRectangle(cornerRadius: CornerRadius.regular)
                .fill(Color(.surface))
                .padding(.vertical, Padding.tiny)
        )
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
