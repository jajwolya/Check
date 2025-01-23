//
//  Inputs.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Padding.regular)
            .submitLabel(.done)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.regular)
                    .fill(Color.surface)
            )
    }
}

extension View {
    func customTextField() -> some View {
        self.modifier(CustomTextFieldStyle())
    }
}
