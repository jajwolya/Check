//
//  SheetPadding.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/1/2025.
//

import SwiftUI

struct SheetPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, Padding.large)
            .padding(.bottom, Padding.medium)
            .padding(.horizontal, Padding.gutter)
    }
}

extension View {
    func sheetPadding() -> some View {
        self.modifier(SheetPadding())
    }
}
