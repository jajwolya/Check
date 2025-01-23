//
//  CategorySelector.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct CategorySelector: View {
//    @EnvironmentObject var viewModel: ListViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @Binding var activeSheet: ActiveEditItemSheet
    let saveAction: () -> Void
    
    var body: some View {
        HStack {
            Text("Category:")
                .foregroundStyle(Color.light)
                .fontWeight(.medium)
            Spacer()
            Button(action: {
                activeSheet = .categories
            }) {
                Text(viewModel.currentCategory?.name ?? "Category")
                    .fontWeight(
                        viewModel.currentCategory != nil
                            ? .semibold : .regular
                    )
                    .foregroundStyle(
                        viewModel.currentCategory != nil
                            ? Color.surfaceBackground
                            : Color.surfaceLight
                    )
                    .padding(.horizontal, Padding.regular)
                    .padding(.vertical, Padding.small)
                    .background(
                        RoundedRectangle(
                            cornerRadius: CornerRadius.medium
                        )
                        .fill(
                            viewModel.currentCategory != nil
                                ? Color.light : Color.surface)
                    )
            }
        }
    }
}
