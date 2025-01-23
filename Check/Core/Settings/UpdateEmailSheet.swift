//
//  UpdateEmailSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/1/2025.
//

import SwiftUI

struct UpdateEmailSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var newEmail: String = ""
    @State var password: String = ""
    var dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color.surfaceDark.ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                Text("Update email address").h3()
                
                Text(
                    "A confirmation email will be sent to your new email address."
                )
                .font(.caption)
                .padding(.bottom, Padding.regular)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField(
                    "",
                    text: $newEmail,
                    prompt: Text("Your new email address").foregroundStyle(
                        Color.surfaceLight)
                )
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .customTextField()

                SecureField("Password", text: $password)
                    .customTextField()

                //                TextField(
                //                    "",
                //                    text: $password,
                //                    prompt: Text("Password").foregroundStyle(Color.surfaceLight)
                //                )
                //                .customTextField()

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
                        disabled: newEmail.isEmpty || password.isEmpty)
                }
            }
            .sheetPadding()
            .presentationDetents([.fraction(0.6)])
            .presentationBackground(.ultraThinMaterial)
        }
    }

    private func confirmAction() async throws {
        try await viewModel.updateEmail(
            newEmail: newEmail, currentPassword: password)
    }
}
