//
//  AddButtonLabel.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/1/2025.
//

import SwiftUI

struct AddButtonLabel: View {
    var body: some View {
        Label("Add list", systemImage: "plus")
            .font(.title2)
            .fontWeight(.semibold)
            .labelStyle(.iconOnly)
            .foregroundStyle(Color.surfaceBackground)
            .frame(
                width: 48,
                height: 48,
                alignment: .center
            )
            .background(
                Circle()
                .fill(Color(.light))
                .shadow(
                    color: .black.opacity(0.2), radius: 2,
                    x: 0,
                    y: 2)
            )
    }
}
