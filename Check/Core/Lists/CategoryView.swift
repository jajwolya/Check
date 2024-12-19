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
    @State var newItem: DBItem = DBItem.defaultNewItem()

    var body: some View {
        Section(header: categoryHeader()) {
            ForEach(category.items.filter { !$0.checked }, id: \.itemId) {
                item in
                itemView(of: item)
                    .swipeActions(allowsFullSwipe: false) {
                        Button(
                            role: .destructive,
                            action: {
                                Task {
                                    do {
                                        try await viewModel.deleteItem(
                                            listId: listId,
                                            categoryId: category.categoryId,
                                            item: item)
                                    } catch {
                                        print("Error deleting item: \(error)")
                                    }
                                }
                            }
                        ) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.alert)
                    }
            }

            ForEach(category.items.filter { $0.checked }, id: \.itemId) {
                item in
                itemView(of: item)
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
            Text(category.name).fontWeight(.semibold)
            Spacer()
            Button(action: {
                viewModel.setCurrentCategory(categoryId: category.categoryId)
                isAddingItem = true
            }) {
                Image(systemName: "plus").padding(Padding.small)
            }.background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceLight)
            )
        }
        .foregroundStyle(Color.white)
    }

    private func inputView() -> some View {
        Group {
            TextField(
                "",
                text: $newItem.name,
                prompt: Text("Item name")
                    .foregroundColor(.surfaceLight)
            )
            .listRowBackground(Color.surface)
            .foregroundStyle(Color.white)
            .onChange(of: newItem.name) {
                print("Name: \(newItem.name)")
            }

            Stepper(
                "Quantity: \(newItem.quantity)", value: $newItem.quantity,
                in: 1...100
            )
            .listRowBackground(Color.surface)
            .foregroundStyle(Color.white)

            TextField("Note", text: $newItem.note, axis: .vertical).lineLimit(
                1...5
            )
            .listRowBackground(Color.surface)
            .foregroundStyle(Color.white)
            .onChange(of: newItem.note) {
                print("Note: \(newItem.note)")
            }

            Button(action: {
                Task {
                    do {
                        try await viewModel.addItem(
                            item: newItem,
                            to: category.categoryId, in: listId)
                        isAddingItem = false
                        newItem = DBItem.defaultNewItem()
                    } catch {
                        print("Error adding item: \(error)")
                    }
                }
            }) {
                Text("Add item")
            }
        }
    }

    private func itemView(of item: DBItem) -> some View {
        //        VStack(spacing: 8) {
        VStack(spacing: 8) {
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
                    HStack {
                        Text(
                            "\(item.name) \(item.quantity > 1 ? "(\(String(item.quantity)))" : "")"
                        ).foregroundStyle(
                            item.checked ? .secondary : .primary
                        )
                        .strikethrough(item.checked)
                        Spacer()
                        Image(
                            systemName: item.checked
                                ? "checkmark.square.fill" : "square")
                    }
                }
            if !item.note.isEmpty {
                Text(item.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        //            Divider().background(Color.surfaceLight)
        //        }
        .listRowSpacing(0)
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.surface))
        .foregroundStyle(.white)
    }
}

//#Preview {
//    NavigationStack {
//        CategoryView(viewModel: ListViewModel(), category: DBCategory(name: "Test category"), listId: "listIdTest")
//    }
//}
