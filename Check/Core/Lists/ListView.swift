//
//  ListView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import SwiftUI

@MainActor final class ListViewModel: ObservableObject {
    @Published private(set) var list: DBList? = nil
    @Published var newCategoryName: String = ""
//    @Published var newItem: DBItem = DBItem(
//        itemId: "", name: "", quantity: 1, note: "", checked: false)
    @Published var currentCategory: String = ""

    func loadList(listId: String) async throws {
        self.list = try await ListManager.shared.getList(listId: listId)
    }

    func addCategory(to listId: String) async throws {
        let category = DBCategory(
            categoryId: UUID().uuidString, name: newCategoryName, items: [])
        try await ListManager.shared
            .addCategory(to: listId, category: category)
        self.list = try await ListManager.shared.getList(listId: listId)
        newCategoryName = ""
    }

    func addItem(item: DBItem, to categoryId: String, in listId: String) async throws {
        let newItem = DBItem(
            itemId: UUID().uuidString,
            name: item.name,
            quantity: item.quantity,
            note: item.note,
            checked: item.checked
        )
        
        print(item)
        try await ListManager.shared
            .addItem(to: listId, categoryId: categoryId, item: item)
        self.list = try await ListManager.shared.getList(listId: listId)
//        newItem = DBItem(
//            itemId: "", name: "", quantity: 1, note: "", checked: false)
    }

    func setCurrentCategory(categoryId: String) {
        currentCategory = categoryId
    }

    func toggleCheckedItem(listId: String, categoryId: String, item: DBItem)
        async throws
    {
        try await ListManager.shared.toggleCheckedItem(
            listId: listId, categoryId: categoryId, item: item)
        self.list = try await ListManager.shared.getList(listId: listId)
    }
}

struct ListView: View {
    @StateObject private var viewModel = ListViewModel()
    @State private var isAddingCategory: Bool = false
    let listId: String

    var body: some View {
        List {
            if let list = viewModel.list {
                ForEach(list.categories, id: \.categoryId) { category in
                    CategoryView(
                        viewModel: viewModel,
                        category: category,
                        listId: listId
                    )
                }
            } else {
                Text("Add a category to get started")
            }
            if isAddingCategory {
                newCategoryView
            }
        }
        .task {
            try? await viewModel.loadList(listId: listId)
        }
        .toolbar {
            toolbarContentView
        }
        .navigationTitle(viewModel.list?.name ?? "Loading...")

    }

    private var toolbarContentView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isAddingCategory = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var newCategoryView: some View {
        TextField(
            "New Category name", text: $viewModel.newCategoryName,
            onCommit: {
                Task {
                    do {
                        try await viewModel.addCategory(to: listId)
                        isAddingCategory = false
                    } catch {
                        print("Error creating list: \(error)")
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        ListView(listId: "listId")
    }
}
