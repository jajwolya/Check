//
//  CustomButton.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/1/2025.
//

import SwiftUI

struct CustomButton: View {
    let text: String
    let action: () -> Void
    let variant: CustomButtonVariant
    var size: CustomButtonSize = .medium
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(fontSize)
                .foregroundStyle(foregroundColor)
                .fontWeight(.medium)
                .padding(padding)
                .frame(
                    maxWidth: size == .medium ? .infinity : nil, alignment: .center
                )
                .background(
                    RoundedRectangle(
                        cornerRadius: CornerRadius.medium
                    )
                    .fill(backgroundColor)
                    .opacity(disabled ? 0.5 : 1)
                )
        }.disabled(disabled)
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return Color.surfaceBackground
        case .secondary:
            return Color.light
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return Color.light
        case .secondary:
            return Color.surface
        }
    }
    
    private var padding: CGFloat {
        switch size {
        case .small:
            return Padding.small
        case .medium:
            return Padding.regular
        }
    }
    
    private var fontSize: Font {
        switch size {
        case .small:
            return .caption
        case .medium:
            return .body
        }
    }
}
