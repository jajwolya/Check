//
//  ListView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import SwiftUI

@MainActor final class ListViewModel: ObservableObject {
    @Published private(set) var list: DBList? = nil
    @Published var currentCategory: String = ""

    func loadList(listId: String) async throws {
        self.list = try await ListManager.shared.getList(listId: listId)
    }

    func addListenerForList(listId: String) {
        ListManager.shared.addListenerForLists(listId: listId) { result in
            switch result {
            case .success(let updatedList):
                self.list = updatedList
            case .failure(let error):
                print("Failed to listen to list updates: \(error)")
            }
        }
    }

    func addCategory(name newCategoryName: String, to listId: String)
        async throws
    {
        let category = DBCategory(name: newCategoryName)
        try await ListManager.shared
            .addCategory(to: listId, category: category)
        self.list = try await ListManager.shared.getList(listId: listId)
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

    func deleteCheckedItems(listId: String) async throws {
        guard var list = list else {
            return
        }

        var updatedCategories: [DBCategory] = []

        for category in list.categories {
            let updatedItems = category.items.filter { !$0.checked }
            let updatedCategory = DBCategory(
                id: category.id,
                name: category.name,
                items: updatedItems
            )
            updatedCategories.append(updatedCategory)
        }

        // Update the list with the updated categories
        list.categories = updatedCategories

        // Assuming `updateCategories` updates all categories in the list
        try await ListManager.shared
            .updateCategories(
                listId: listId,
                updatedCategories: list.categories
            )

        // Optionally fetch the updated list
        self.list = try await ListManager.shared.getList(listId: listId)
    }

    func deleteCategory(listId: String, categoryId: String) async throws {
        try await ListManager.shared.deleteCategory(
            listId: listId, categoryId: categoryId)
        self.list = try await ListManager.shared.getList(listId: listId)
    }
    
    func updateItemOrder(listId: String, categoryId: String, updatedItems: [DBItem]) async throws {
        try await ListManager.shared.updateCategoryItems(
            listId: listId, categoryId: categoryId, with: updatedItems)
        self.list = try await ListManager.shared.getList(listId: listId)
    }
}

struct ListView: View {
    @StateObject private var viewModel = ListViewModel()
    @FocusState private var focusedField: Bool
    @State private var isAddingCategory: Bool = false
    @State private var isSharing: Bool = false
    @State private var didAppear: Bool = false
    @State private var newCategoryName: String = ""
    var listId: String
    var listName: String
    //    var list: DBList

    var body: some View {
        List {
            if let list = viewModel.list, !list.categories.isEmpty {
                ForEach(list.categories, id: \.id) { category in
                    CategoryView(
                        category: category,
                        listId: listId
                    ).listRowInsets(EdgeInsets())
                        .environmentObject(viewModel)
                }
            }
            if let list = viewModel.list,
                list.categories.isEmpty || isAddingCategory
            {
                Section {
                    newCategoryView
                        .focused($focusedField)
                        .onAppear {
                            self.focusedField = true
                        }
                }
            }
        }
        .onAppear {
            if !didAppear {
                viewModel.addListenerForList(listId: listId)
                didAppear = true
            }
        }
        .task {
            do {
                try await viewModel.loadList(listId: listId)
            } catch {
                print("Error loading list: \(error)")
            }
        }
        //        List {
        //            if !list.categories.isEmpty {
        //                ForEach(list.categories, id: \.categoryId) { category in
        //                    CategoryView(
        //                        category: category,
        //                        listId: list.listId
        //                    ).listRowInsets(EdgeInsets())
        //                        .environmentObject(viewModel)
        //                }
        //            }
        //            if list.categories.isEmpty || isAddingCategory {
        //                Section("Category heading") {
        //                    newCategoryView
        //                }
        //            }
        //        }
        .padding(.top, 64)
        .listSectionSpacing(.compact)
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color.surfaceBackground)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)
        .overlay {
            NavigationBarList(
                title: listName,
                isAdding: $isAddingCategory,
                isSharing: $isSharing,
                listId: listId
            ).environmentObject(viewModel)
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(
                isSharing: $isSharing,
                listId: listId,
                users: viewModel.list?.users ?? []
            )
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
            "", text: $newCategoryName,
            prompt: Text("Category name")
                .foregroundStyle(Color.surfaceLight)
        )
        .foregroundStyle(Color.white)
        .listRowBackground(Color.surface)
        .background(RoundedRectangle(cornerRadius: 8).fill(.surface))
        .submitLabel(.done)
        .padding(.vertical, Padding.small)
        .onSubmit {
            Task {
                do {
                    try await viewModel.addCategory(
                        name: newCategoryName, to: listId)
                    isAddingCategory = false
                    newCategoryName = ""
                } catch {
                    print("Error creating list: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        ListView(listId: "listId")
//    }
//}
