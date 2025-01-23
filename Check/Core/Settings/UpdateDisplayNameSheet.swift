//
//  UpdateDisplayNameSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 22/1/2025.
//

import SwiftUI

struct UpdateDisplayNameSheet: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var newDisplayName: String = ""
    var dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color.surfaceDark.ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                Text("Update display name").h3()
                
                TextField(
                    "",
                    text: $newDisplayName,
                    prompt: Text("Your new display name").foregroundStyle(
                        Color.surfaceLight)
                )
                .disableAutocorrection(true)
                .customTextField()
                
                if let user = viewModel.dbUser {
                    Text("Current display name: \(user.displayName)")
                        .font(.caption)
                        .padding(.top, Padding.regular)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

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
                        disabled: newDisplayName.isEmpty)
                }
            }
            .sheetPadding()
            .presentationDetents([.fraction(0.6)])
            .presentationBackground(.ultraThinMaterial)
        }
    }

    private func confirmAction() async throws {
        try await viewModel.updateDisplayName(
            newDisplayName: newDisplayName)
    }
}
