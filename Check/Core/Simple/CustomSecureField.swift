//
//  CustomSecureField.swift
//  Check
//
//  Created by Jajwol Bajracharya on 15/1/2025.
//

import SwiftUI

struct CustomSecureField: View {
    @EnvironmentObject var viewModel: SignInEmailViewModel
    //    @Binding private var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        ZStack(alignment: .trailing) {
            inputField
            toggleSecureButton
        }

    }

    private var inputField: some View {
        Group {
            if isSecure {
                SecureField("Password", text: $viewModel.password)
            } else {
                TextField("Password", text: $viewModel.password)
            }
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding(Padding.regular)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.regular)
                .fill(Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.regular)
                .stroke(
                    viewModel.passwordError != nil
                        ? Color.surfaceLight : Color.clear)
        )
    }

    private var toggleSecureButton: some View {
        Button(action: { isSecure.toggle() }) {
            Image(systemName: isSecure ? "eye.slash" : "eye")
                .tint(Color.surfaceLight)
                .padding(Padding.regular)
        }
    }
}
