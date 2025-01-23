//
//  CustomStepper.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct CustomStepper: View {
    @Binding var item: DBItem
    
    var body: some View {
        HStack(spacing: Padding.regular) {
            Text("Quantity:").foregroundStyle(Color.light).fontWeight(
                .medium)

            Spacer()
            
            Text("\(item.quantity)").foregroundStyle(Color.light)
                .fontWeight(.medium)
            
            HStack(spacing: 0) {
                Button(action: {
                    item.quantity -= 1
                }) {
                    Image(systemName: "minus")
                        .frame(width: 48, height: 48)
                }.buttonStyle(.borderless)
                    .opacity(item.quantity == 1 ? 0.5 : 1)
                    .disabled(item.quantity == 1)

                Divider()
                    .background(Color.surfaceDark)
                    .frame(height: 32)

                Button(action: { item.quantity += 1 }) {
                    Image(systemName: "plus")
                        .frame(width: 48, height: 48)
                }.buttonStyle(.borderless)
            }
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.regular)
                    .fill(
                        Color.surface))
        }
    }
}
