//
//  EditItemSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 2/1/2025.
//

import SwiftUI

struct ItemSheet: View {
    enum FocusedField {
        case itemName
    }

    //    @EnvironmentObject var viewModel: ListViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @FocusState private var focusedField: FocusedField?
    @Binding var item: DBItem
    let listId: String
    var isEditing: Bool = false
    @Binding var activeSheet: ActiveEditItemSheet
    var dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                Text(isEditing ? "Edit item" : "Add item").h3()

                TextField("Item name", text: $item.name)
                    .customTextField()
                    .focused($focusedField, equals: .itemName)

                TextField(
                    "",
                    text: $item.note,
                    prompt: Text("Note").foregroundStyle(Color.surfaceLight)
                )
                .customTextField()

                CustomStepper(item: $item)

                //                CategorySelector(activeSheet: $activeSheet, saveAction: saveAction)
                //                    .environmentObject(homeViewModel)

                Spacer()

                HStack(spacing: Padding.regular) {
                    CustomButton(
                        text: "Cancel",
                        action: {
                            dismissAction()
                            dismissAction()
                        },
                        variant: .secondary)

                    CustomButton(
                        text: isEditing ? "Save" : "Add",
                        action: {
                            isEditing ? saveAction() : addAction()
                            dismissAction()
                        },
                        variant: .primary, disabled: item.name.isEmpty)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(Color.content)
            .sheetPadding()
        }
        .presentationDetents([.fraction(1)])
        .presentationBackground(.ultraThinMaterial)
        .onAppear {
            focusedField = .itemName
        }
    }

    private func deleteAction() {
        if let categoryId = homeViewModel.currentCategory?
            .id
        {
            Task {
                do {
                    try await homeViewModel
                        .deleteItem(
                            listId: listId,
                            categoryId: categoryId,
                            item: item)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }

    private func addAction() {
        if let categoryId = homeViewModel.currentCategory?.id {
            Task {
                do {
                    try await homeViewModel.addItem(
                        item: item, to: categoryId,
                        in: listId)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }

    private func saveAction() {
        if let categoryId = homeViewModel.currentCategory?.id,
            let previousCategoryId = homeViewModel.previousCategory?
                .id
        {
            Task {
                do {
                    try await homeViewModel
                        .deleteItem(
                            listId: listId,
                            categoryId: previousCategoryId,
                            item: item)
                    try await homeViewModel.addItem(
                        item: item, to: categoryId,
                        in: listId)

                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
