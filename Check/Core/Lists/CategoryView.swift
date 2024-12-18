//
//  CategoryView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 18/12/2024.
//

import SwiftUI

struct CategoryView: View {
    @StateObject var viewModel: ListViewModel
    let category: DBCategory
    let listId: String

    @State private var isAddingItem: Bool = false
    @State var newItem: DBItem = DBItem(
        itemId: "", name: "", quantity: 1, note: "", checked: false)

    var body: some View {
        Section(header: categoryHeader()) {
            ForEach(category.items, id: \.itemId) { item in
                Button(
                    action: {
                        Task {
                            do {
                                try await viewModel.toggleCheckedItem(
                                    listId: listId,
                                    categoryId: category.categoryId,
                                    item: item
                                )
                            } catch {
                                print("Error updating item: \(error)")
                            }
                        }
                    }) {
                        Text(item.name).strikethrough(item.checked)
                    }
            }
        }
        if isAddingItem
            && viewModel.currentCategory == category.categoryId
        {
            inputView()
        }
    }

    private func categoryHeader() -> some View {
        HStack {
            Text(category.name)
            Spacer()
            Button(action: {
                viewModel.setCurrentCategory(categoryId: category.categoryId)
                isAddingItem = true
            }) {
                Image(systemName: "plus")
            }
        }
    }

    private func inputView() -> some View {
        Group {
            TextField(
                "New Item name",
                text: $newItem.name
            )
            Stepper(
                "Quantity: \(newItem.quantity)", value: $newItem.quantity,
                in: 1...100)
            TextField("Note", text: $newItem.note, axis: .vertical).lineLimit(
                1...5).onChange(of: newItem.note) {
                    print("Note: \(newItem.note)")
                }
            Button(action: {
                Task {
                    do {
                        try await viewModel.addItem(item: newItem,
                            to: category.categoryId, in: listId)
                        isAddingItem = false
                    } catch {
                        print("Error adding item: \(error)")
                    }
                }
            }) {
                Text("Add item")
            }
        }
    }
}
