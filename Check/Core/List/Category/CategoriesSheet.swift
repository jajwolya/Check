//
//  CategoriesSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 10/1/2025.
//

import SwiftUI

struct CategoriesSheet: View {
//    @EnvironmentObject var viewModel: ListViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    //    @State var item: DBItem
    let categories: [DBCategory]
    //    var currentCategory: DBCategory? = nil
    var dismissAction: () -> Void
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(alignment: .leading, spacing: Padding.regular) {
                Text("Categories").h3()
                LazyVGrid(columns: columns, spacing: Padding.regular) {
                    ForEach(categories, id: \.id) { category in
                        Category(category: category)
                    }
                }
                
                Spacer()
                
                CustomButton(text: "Go back", action: {dismissAction()}, variant: .secondary)

            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(Color.content)
            .sheetPadding()
        }
        .presentationDetents([.fraction(0.5), .fraction(0.8)])
        .presentationBackground(.ultraThinMaterial)
    }

    private func Category(category: DBCategory) -> some View {
        Button(action: {
            if viewModel.currentCategory != nil {
                viewModel
                    .setPreviousCategory(category: viewModel.currentCategory)
            }
            viewModel.setCurrentCategory(category: category)
            dismissAction()
        }) {
            Text(category.name)
                .fontWeight(
                    viewModel.currentCategory?.id == category.id
                        ? .semibold : .regular
                )
                .padding(.horizontal, Padding.regular)
                .padding(.vertical, Padding.small)
                .foregroundStyle(
                    viewModel.currentCategory?.id == category.id
                        ? Color.surfaceBackground : Color.light
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(
                            viewModel.currentCategory?.id == category.id
                                ? Color.light : Color.surface)
                )

        }
    }
}

//#Preview {
//    let item = DBItem(name: "Bread", quantity: 2, note: "Rye", checked: false)
//    EditItemSheet(item: item)
//}
