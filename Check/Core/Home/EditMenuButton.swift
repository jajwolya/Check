//
//  EditMenuButton.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct EditMenuButton: View {
    @Binding var showEditMenu: Bool
    @Binding var activeSheet: ActiveListSheet?
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom, spacing: Padding.regular) {
                if showEditMenu {
                    VStack(alignment: .trailing, spacing: Padding.regular) {
                        Button(action: {
                            activeSheet = .addingCategory
                            withAnimation { showEditMenu = false }
                        }) {
                            Label(
                                "Add category", systemImage: "folder.badge.plus"
                            ).padding(Padding.regular)
                                .foregroundStyle(Color.surfaceBackground).background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(Color.light)
                                )
                        }

                        Button(action: {
                            activeSheet = .addingItem
                            withAnimation { showEditMenu = false }
                        }) {
                            Label(
                                "Add item", systemImage: "plus.circle"
                            ).padding(Padding.regular)
                                .foregroundStyle(Color.surfaceBackground)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(Color.light)
                                )
                        }
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            showEditMenu.toggle()
                        }
                    }) {
                        Label("Add category or item", systemImage: "plus")
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
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(Padding.gutter)
    }
}
