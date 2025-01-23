//
//  Typography.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/1/2025.
//

import SwiftUI

struct Heading3Modifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.bottom, Padding.regular)
            .foregroundStyle(Color.light)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func h3() -> some View {
        self.modifier(Heading3Modifier())
    }
}
