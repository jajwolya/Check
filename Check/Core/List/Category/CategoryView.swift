//
//  CategoryView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    var list: DBList
    var category: DBCategory
    @Binding var activeSheet: SheetType?

    var body: some View {

        Section(header: categoryHeader) {
            if viewModel.isCategoryOpen(categoryId: category.id) {
                if category.items.isEmpty { emptyCategoryView }
                ForEach(
                    Array(category.items.filter { !$0.checked }.enumerated()),
                    id: \.element.id
                ) { index, item in
                    if index >= 1 {
                        Divider().background(Color.surfaceLight)
                    }
                    itemView(of: item)
                }
                .onMove(perform: moveItems)

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
        }
        if viewModel.isCategoryOpen(categoryId: category.id) {
            HStack {
                Spacer()
                Button(action: {
                    viewModel.setCurrentCategory(category: category)
                    activeSheet = .addingItem
                }) {
                    HStack(spacing: Padding.small) {
                        Image(systemName: "plus")
                        Text("Item")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.light)
                    .frame(
                        alignment: .center
                    )
                    .padding(Padding.small)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color(.surface))
                    )
                }.buttonStyle(.borderless)
            }
            .listRowBackground(Color.clear)
            Spacer().frame(maxHeight: 16).listRowBackground(Color.clear)
        }

    }

    private var categoryHeader: some View {
        HStack(spacing: Padding.regular) {
            Text(category.name)
                .fontWeight(.medium)
            let uncheckedItems = category.items.filter { !$0.checked }
            if !viewModel.isCategoryOpen(categoryId: category.id)
                && !uncheckedItems.isEmpty
            {
                Text("\(uncheckedItems.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, Padding.small)
                    .padding(.vertical, Padding.tiny)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color.primaryLight)
                    )
            }
            Spacer()
            if !viewModel.isReorderingCategories {
                HStack(spacing: Padding.regular) {
                    Menu {
                        Button(action: {
                            viewModel.setCurrentCategory(category: category)
                            activeSheet = .renameCategory
                        }) {
                            Label(
                                "Rename category",
                                systemImage: "square.and.pencil")
                        }
                        Button(action: {
                            viewModel.setCurrentCategory(category: category)
                            if !category.items.isEmpty {
                                activeSheet = .deleteCategory
                            } else {
                                Task {
                                    do {
                                        try await viewModel
                                            .deleteCategory(
                                                listId: list.listId,
                                                categoryId: category.id)
                                    }
                                }
                            }
                        }) {
                            Label(
                                "Delete category",
                                systemImage: "minus.circle")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                            .foregroundStyle(Color.surfaceLight)
                            .labelStyle(.iconOnly)
                            .frame(width: 32, height: 32, alignment: .center)
                    }

                    Button(action: {
                        withAnimation {
                            viewModel.toggleCategoryOpen(
                                categoryId: category.id)
                        }
                    }) {
                        Image(
                            systemName: viewModel.isCategoryOpen(
                                categoryId: category.id)
                                ? "chevron.up" : "chevron.down")
                    }.buttonStyle(.borderless)
                }
            }
            if viewModel.isReorderingCategories {
                HStack(spacing: Padding.regular) {
                    if let index = viewModel.currentList?.categories.firstIndex(
                        where: { $0.id == category.id })
                    {
                        let isFirst = index == 0
                        let isLast =
                            index
                            == (viewModel.currentList?.categories.count ?? 1)
                            - 1
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.moveCategoryDown(
                                        category: category)
                                }
                            }
                        }) {
                            Image(systemName: "arrow.down")
                                .frame(width: 32, height: 32)
                                .foregroundStyle(
                                    isLast ? Color.surfaceLight : Color.light
                                )
                                .background(
                                    Circle().fill(Color.surface)
                                )
                        }.buttonStyle(.borderless)

                        Button(
                            action: {
                                Task {
                                    do {
                                        try await viewModel
                                            .moveCategoryUp(
                                                category: category
                                            )
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.up")
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(
                                        isFirst
                                            ? Color.surfaceLight : Color.light
                                    )
                                    .background(
                                        Circle().fill(Color.surface)
                                    )
                            }.buttonStyle(.borderless)
                    }

                }.listRowBackground(Color.clear)
            }
        }
        .padding(.horizontal, Padding.gutter)
        .padding(.vertical, Padding.small)
        .headerProminence(.increased)
        .font(.body)
        .foregroundStyle(Color.content)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.regular).fill(
                viewModel.isCategoryOpen(categoryId: category.id)
                    ? Color.clear : Color.surfaceDark)
        )
        .onTapGesture {
            withAnimation {
                viewModel.toggleCategoryOpen(
                    categoryId: category.id)
            }
        }
    }

    private func itemView(of item: DBItem) -> some View {
        VStack(spacing: Padding.tiny) {
            Button(
                action: {
                    Task {
                        do {
                            try await viewModel.toggleItem(
                                listId: list.listId,
                                categoryId: category.id,
                                item: item
                            )
                        } catch {
                            print("Error updating item: \(error)")
                        }
                    }
                }) {
                    Text(
                        "\(item.name) \(item.quantity > 1 ? "(\(String(item.quantity)))" : "")"
                    ).foregroundStyle(
                        item.checked ? .secondary : .primary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .strikethrough(item.checked)
                }
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
        .foregroundStyle(Color.content)
        //        .onAppear {
        //            focusedField = .name
        //        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteItem(
                            listId: list.listId,
                            categoryId: category.id,
                            item: item
                        )
                    } catch {
                        print("Error deleting item: \(error)")
                    }
                }
            } label: {
                Text("Delete").foregroundStyle(Color.light)
            }
            .tint(.alert)

            Button {
                viewModel.setCurrentItem(item: item)
                viewModel.setCurrentCategory(category: category)
                viewModel.setPreviousCategory(category: category)
                activeSheet = .editingItem
            } label: {
                Text("Edit").foregroundStyle(Color.light)
            }
            .tint(Color.surfaceDark)
        }
    }

    private var emptyCategoryView: some View {
        Text("No items")
            .padding(.horizontal, Padding.gutter)
            .padding(.vertical, Padding.small)
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.surfaceDark))
            .foregroundStyle(.contentFaded)
    }

    private func moveItems(indexSet: IndexSet, destination: Int) {
        Task {
            do {
                try await moveItemsInList(
                    indexSet: indexSet, destination: destination)
            } catch {
                print("Error moving categories: \(error)")
            }
        }
    }

    private func moveItemsInList(
        indexSet: IndexSet, destination: Int
    ) async throws {
        var uncheckedItems = category.items.filter { !$0.checked }
        uncheckedItems.move(
            fromOffsets: indexSet,
            toOffset: destination
        )
        let checkedItems = category.items.filter { $0.checked }
        let items = uncheckedItems + checkedItems
        try await viewModel
            .updateItemOrder(
                listId: list.listId, categoryId: category.id,
                updatedItems: items)
    }
}

//#Preview {
//    NewCategoryView()
//}
