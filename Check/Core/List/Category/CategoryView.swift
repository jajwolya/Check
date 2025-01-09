//
//  CategoryView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 18/12/2024.
//

import SwiftUI

struct CategoryView: View {
    enum FocusedField: Hashable {
        case name
        case note
    }

    @EnvironmentObject var viewModel: ListViewModel
    var category: DBCategory
    let listId: String
    @FocusState private var focusedField: FocusedField?

    @State private var isAddingItem: Bool = false
    @State var newItem: DBItem = DBItem.defaultNewItem()
    @State private var isShowingDialog = false
    @State private var draggedItem: DBItem?

    var body: some View {
        Section(header: categoryHeader(category: category)) {
            ForEach(
                Array(category.items.filter { !$0.checked }.enumerated()),
                id: \.element.id
            ) { index, item in
                if index >= 1 {
                    Divider().background(Color.surfaceLight)
                }
                itemView(of: item)
                    .onAppear {
                        focusedField = .name
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(
                            role: .destructive,
                            action: {
                                Task {
                                    do {
                                        try await viewModel.deleteItem(
                                            listId: listId,
                                            categoryId: category.id,
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
            .onMove(
                perform: {
                    indexSet,
                    destination in
                    Task {
                        do {
                            try await moveItems(
                                indexSet: indexSet,
                                destination: destination
                            )
                        } catch {
                            print("Error reordering items: \(error)")
                        }
                    }
                })

            ForEach(
                Array(category.items.filter { $0.checked }.enumerated()),
                id: \.element.id
            ) { index, item in
                if index >= 1 {
                    Divider().background(Color.surfaceLight)
                }
                itemView(of: item)
            }
        }

        if isAddingItem
            && viewModel.currentCategory == category.id
        {
            inputView()
        }
    }

    private func moveItems(
        indexSet: IndexSet, destination: Int
    ) async throws {
        var uncheckedItems = category.items.filter { !$0.checked }
        uncheckedItems.move(
            fromOffsets: indexSet,
            toOffset: destination
        )
        var checkedItems = category.items.filter { $0.checked }
        let items = uncheckedItems + checkedItems
        try await viewModel
            .updateItemOrder(listId: listId, categoryId: category.id, updatedItems: items)
    }

    private func categoryHeader(category: DBCategory) -> some View {
        HStack {
            Text(category.name).fontWeight(.semibold)
            Spacer()
            HStack(spacing: Padding.regular) {
                Button(action: {
                    isShowingDialog = true
                }) {
                    Image(systemName: "folder.badge.minus")
                }
                .confirmationDialog(
                    "Are you sure you want to delete this category?",
                    isPresented: $isShowingDialog,
                    titleVisibility: .visible
                ) {
                    Button("Delete category", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.deleteCategory(
                                    listId: listId,
                                    categoryId: category.id)
                            } catch {
                                print("Error deleting category: \(error)")
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingDialog = false
                    }
                }

                Button(action: {
                    viewModel.setCurrentCategory(
                        categoryId: category.id)
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
            )
            .focused($focusedField, equals: .name)
            .frame(maxHeight: .infinity, alignment: .center)
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
                            to: category.id, in: listId)
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
                HStack(spacing: 0) {
                    Button(action: {
                        if newItem.quantity > 1 {
                            newItem.quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 24)
                    }.buttonStyle(.borderless)
                    Divider().background(.surfaceLight)
                    Button(action: { newItem.quantity += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 32, height: 24)

                    }.buttonStyle(.borderless)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.surfaceLight))

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
            .focused($focusedField, equals: .note)
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
                                to: category.id, in: listId)
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
                    RoundedRectangle(cornerRadius: 8).fill(
                        newItem.name.isEmpty
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
        VStack(spacing: Padding.small) {
            Button(
                action: {
                    Task {
                        do {
                            try await viewModel.toggleCheckedItem(
                                listId: listId,
                                categoryId: category.id,
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
        .listRowSeparator(.hidden)
        .listRowBackground(Color(item.checked ? .surfaceDark : .surface))
        .foregroundStyle(.white)
        //        .onDrag {
        //            draggedItem = item
        //            return NSItemProvider()
        //        }
        //        .onDrop(
        //            of: [.text],
        //            delegate: DropViewDelegate(
        //                destinationItem: item,
        //                colors: $category.items,
        //                draggedItem: $draggedItem
        //            )
        //        )
    }
}

//#Preview {
//    NavigationStack {
//        CategoryView(
//            viewModel: ListViewModel(),
//            category: DBCategory(name: "Test category"), listId: "listIdTest")
//    }
//}
