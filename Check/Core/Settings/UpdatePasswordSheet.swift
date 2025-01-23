//
//  UpdatePasswordSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/1/2025.
//

import SwiftUI

struct UpdatePasswordSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var newPassword: String = ""
    @State var currentPassword: String = ""
    let dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color.surfaceDark.ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                Text("Update password").h3()
                
                SecureField("Your new password", text: $newPassword)
                    .customTextField()
                
//                TextField(
//                    "",
//                    text: $newPassword,
//                    prompt: Text("Your new password").foregroundStyle(
//                        Color.surfaceLight)
//                )
//                .customTextField()

//                TextField(
//                    "",
//                    text: $currentPassword,
//                    prompt: Text("Current password").foregroundStyle(
//                        Color.surfaceLight)
//                )
//                .customTextField()
                
                SecureField("Current password", text: $currentPassword)
                    .customTextField()
                
                Spacer()

                HStack(spacing: Padding.regular) {
                    CustomButton(
                        text: "Cancel",
                        action: {
                            dismissAction()
                        },
                        variant: .secondary)

                    CustomButton(
                        text: "Confirm",
                        action: {
                            Task {
                                do {
                                    try await confirmAction()
                                    dismissAction()
                                } catch {

                                }
                            }
                        },
                        variant: .primary,
                        disabled: newPassword.isEmpty || currentPassword.isEmpty)
                }
            }
            .sheetPadding()
            .presentationDetents([.fraction(0.6)])
            .presentationBackground(.ultraThinMaterial)
        }
    }

    private func confirmAction() async throws {
        try await viewModel.updatePassword(
            newPassword: newPassword, currentPassword: currentPassword)
    }
}
