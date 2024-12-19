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
        let category = DBCategory(name: newCategoryName)
        try await ListManager.shared
            .addCategory(to: listId, category: category)
        self.list = try await ListManager.shared.getList(listId: listId)
        newCategoryName = ""
    }

    func addItem(item: DBItem, to categoryId: String, in listId: String)
        async throws
    {
        try await ListManager.shared
            .addItem(to: listId, categoryId: categoryId, item: item)
        self.list = try await ListManager.shared.getList(listId: listId)
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

    func deleteItem(listId: String, categoryId: String, item: DBItem)
        async throws
    {
        try await ListManager.shared.deleteItem(
            listId: listId, categoryId: categoryId, item: item)
        self.list = try await ListManager.shared.getList(listId: listId)
    }

}

struct ListView: View {
    @StateObject private var viewModel = ListViewModel()
    @State private var isAddingCategory: Bool = false
    @State private var isSharing: Bool = false
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
        .scrollContentBackground(.hidden)
        .background(Color(.surfaceDark))
        .padding(.top, 48)
        .overlay {
            NavigationBar(title: viewModel.list?.name ?? "")
        }
        .task {
            try? await viewModel.loadList(listId: listId)
        }
        .toolbar {
            toolbarContentView
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(isSharing: $isSharing, listId: listId)
        }

    }

    private var toolbarContentView: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: Padding.small) {
                Button(action: {
                    isSharing = true
                }) {
                    Image(systemName: "square.and.arrow.up").foregroundStyle(
                        Color.white)
                }
                Button(action: {
                    isAddingCategory = true
                }) {
                    Image(systemName: "plus")
                        .padding(Padding.tiny)
                        .foregroundStyle(Color.white)
                        .background(
                            Circle().fill(Color.surface).shadow(
                                color: .black.opacity(0.2), radius: 2, x: 0,
                                y: 2))
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
