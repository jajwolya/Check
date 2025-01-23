//
//  CategorySheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 8/1/2025.
//

import SwiftUI

struct CategorySheet: View {
    //    @EnvironmentObject var viewModel: ListViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @State var validateDeletion: Bool = false
    @State var category: DBCategory
    var listId: String
    var isEditing: Bool = false
    var dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.medium) {
                Text(isEditing ? "Rename category" : "Add category").h3()

                TextField(
                    "\(category.name)", text: $category.name,
                    prompt: Text("Category name")
                )
                .disableAutocorrection(true)
                .customTextField()

//                if isEditing {
//                    moveCategoryField
//                    clearCategoryField
//                }

                Spacer()

                HStack(spacing: Padding.regular) {
                    CustomButton(
                        text: "Cancel",
                        action: {
                            dismissAction()
                        },
                        variant: .secondary)
                    CustomButton(
                        text: isEditing ? "Save" : "Add",
                        action: {
                            isEditing ? saveAction() : addAction()
                        },
                        variant: .primary, disabled: category.name.isEmpty)
                }
            }
            .sheetPadding()
        }
        .presentationDetents([.fraction(0.5)])
        .presentationBackground(.ultraThinMaterial)
    }

    private func saveAction() {
        Task {
            do {
                try await viewModel
                    .updateCategoryName(
                        listId: listId,
                        categoryId: category.id,
                        categoryName: category.name)
                dismissAction()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    private func addAction() {
        Task {
            do {
                try await viewModel.addCategory(
                    name: category.name, to: listId)
                dismissAction()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    private var moveCategoryField: some View {
        HStack(spacing: Padding.regular) {
            VStack(alignment: .leading) {
                Text("Move category").fontWeight(.medium)
                //                if let position = viewModel.getCategoryPosition(
                //                    categoryId: category.id)
                //                {
                //                    Text("Current position: \(position + 1)")
                //                        .font(.caption)
                //                        .foregroundStyle(Color.surfaceLight)
                //                }
            }

            Spacer()

            Button(action: {
                Task {
                    do {
                        try await viewModel.moveCategoryDown(
                            category: category)
                    }
                }
            }) {
                Image(systemName: "chevron.down")
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color.light)
                    .background(
                        Circle().fill(Color.surface)
                    )
            }

            Button(
                action: {
                    Task {
                        do {
                            try await viewModel.moveCategoryUp(
                                category: category
                            )
                        }
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.light)
                        .background(
                            Circle().fill(Color.surface)
                        )
                }
        }
    }

//    private var clearCategoryField: some View {
//        HStack {
//            CustomButton(
//                text: "Remove all items",
//                action: {
//                    Task {
//                        do {
//                            try await viewModel.deleteItems()
//                        }
//                    }
//                },
//                variant: .secondary
//            )
//        }
//    }
}
