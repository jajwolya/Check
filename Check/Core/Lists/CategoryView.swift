//
//  CategoryView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 18/12/2024.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var viewModel: ListViewModel
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
            HStack(spacing: Padding.regular) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.deleteCategory(
                                listId: listId, categoryId: category.categoryId)
                        } catch {
                            print("Error deleting category: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "trash")
                }
                Button(action: {
                    viewModel.setCurrentCategory(
                        categoryId: category.categoryId)
                    isAddingItem = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .padding(.horizontal, Padding.gutter)
        .padding(.vertical, Padding.regular)
        .headerProminence(.increased)
        .foregroundStyle(Color.white)
    }

    private func sectionHeader(header: String) -> some View {
        HStack {
            Text(header).font(.caption)
        }
        .padding(.horizontal, Padding.gutter)
        .padding(.vertical, Padding.regular)
        .foregroundStyle(Color.surfaceLight)
    }

    private func inputView() -> some View {
        //        VStack {
        VStack {
                TextField(
                    "",
                    text: $newItem.name,
                    prompt: Text("Name")
                        .foregroundStyle(Color.surfaceLight)
                ).frame(maxHeight: .infinity, alignment: .center)
                    .padding(Padding.small)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(Color.surface)
                    )
                    .submitLabel(.done)
                    .onSubmit {
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
                    }
            

            //            Divider().background(.surfaceLight)

            //            Stepper(
            //                "Quantity: \(newItem.quantity)", value: $newItem.quantity,
            //                in: 1...100
            //            ).frame(maxHeight: .infinity, alignment: .center)
            
                HStack(spacing: Padding.small) {
                    Text("Quantity: ").foregroundStyle(Color.surfaceLight)
                    Text("\(newItem.quantity)")
                    Spacer()

                    Button(action: {
                        if newItem.quantity > 1 {
                            newItem.quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.surfaceLight))
                    }.buttonStyle(.borderless)

                    Button(action: { newItem.quantity += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.surfaceLight))
                    }.buttonStyle(.borderless)

                }.padding(Padding.small)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.surface)
                )
            

            //            Divider().background(.surfaceLight)

                TextField(
                    "",
                    text: $newItem.note,
                    prompt: Text("Note").foregroundStyle(Color.surfaceLight)
                )
                .lineLimit(
                    1...5
                ).frame(maxHeight: .infinity, alignment: .center)
                .padding(Padding.small)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.surface)
                )

            //            Divider().background(.surfaceLight)

            HStack {
                Button(action: {
                    isAddingItem = false
                    newItem = DBItem.defaultNewItem()
                }) {
                    Text("Cancel")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.borderless)
                .padding(Padding.small)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.surfaceDark)
                )
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
                        .foregroundStyle(
                            newItem.name.isEmpty
                                ? Color.surfaceLight : Color.white
                        )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.borderless)
                .disabled(newItem.name.isEmpty)
                .padding(Padding.small)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(newItem.name.isEmpty
                                                           ? Color.surface : Color.brandPrimary)
                )
            }
            .listRowBackground(Color.clear)
            .frame(maxHeight: .infinity, alignment: .center)
        }
        //        }
        .padding(Padding.regular)
        //        //        .listRowSeparator(.hidden)
        //        .listRowSeparatorTint(.red)
        .listRowBackground(Color.clear)
        .foregroundStyle(Color.white)
        .shadow(
            color: .black.opacity(0.2), radius: 2, x: 0,
            y: 2)
    }

    private func itemView(of item: DBItem) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: Padding.small) {
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
                            //                            Spacer()
                            //                            Image(
                            //                                systemName: item.checked
                            //                                    ? "checkmark.square.fill" : "square")
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                if !item.note.isEmpty && !item.checked {
                    Text(item.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, Padding.gutter)
            .padding(.vertical, Padding.small)

            Divider().background(Color.surfaceLight)
        }

        //        .background(.red)
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.surface))
        .foregroundStyle(.white)
    }
}

//#Preview {
//    NavigationStack {
//        CategoryView(
//            viewModel: ListViewModel(),
//            category: DBCategory(name: "Test category"), listId: "listIdTest")
//    }
//}
