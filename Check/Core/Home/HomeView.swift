//
//  HomeView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

@MainActor final class HomeViewModel: ObservableObject {
    @Published private(set) var currentUser: DBUser? = nil
    @Published private(set) var currentList: DBList? = nil
    @Published private(set) var lists: [DBList]? = nil

    @Published private(set) var currentCategory: DBCategory? = nil
    @Published private(set) var previousCategory: DBCategory? = nil
    @Published private(set) var categoryOpenState: [String: Bool] = [:]

    @Published private(set) var currentItem: DBItem? = nil
    @Published private(set) var isReorderingCategories: Bool = false

    // Loading functions

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared
            .getAuthenticatedUser()
        self.currentUser = try await UserManager.shared
            .getUser(userId: authDataResult.uid)
    }

    func loadLists() async throws {
        if let userLists = currentUser?.lists {
            var lists: [DBList] = []
            for userList in userLists {
                let list = try await ListManager.shared.getList(
                    listId: userList.id)
                lists.append(list)
            }
            self.lists = lists
        }
    }

    // Get functions

    func getCategoryPosition(categoryId: String) -> Int? {
        guard let categories = currentList?.categories else { return nil }
        return categories.firstIndex(where: { $0.id == categoryId })
    }

    // Setting functions

    func setCurrentList(list: DBList?) {
        self.currentList = list
    }

    func setCurrentCategory(category: DBCategory?) {
        self.currentCategory = category
    }

    func setPreviousCategory(category: DBCategory?) {
        self.previousCategory = category
    }

    func setCurrentItem(item: DBItem?) {
        self.currentItem = item
    }

    func toggleReorderingCategories() {
        withAnimation {
            isReorderingCategories.toggle()
        }
    }

    // Adding functions

    func addListListener(listId: String) {
        ListManager.shared.addListListener(listId: listId) { result in
            switch result {
            case .success(let updatedList):
                self.currentList = updatedList
            case .failure(let error):
                print("Failed to listen to list updates: \(error)")
            }
        }
    }

    func addUserListener(userId: String) {
        UserManager.shared.addUserListener(userId: userId) { result in
            switch result {
            case .success(let updatedUser):
                self.currentUser = updatedUser
            case .failure(let error):
                print("Failed to listen to user updates: \(error)")
            }
        }
    }

    func addNewList(listName: String) async throws {
        guard let currentUser,
            let listId = try? await ListManager.shared.createNewList(
                name: listName, userId: currentUser.userId)
        else {
            if currentUser == nil {
                throw UserError.notLoggedIn(
                    "User must be logged in to create a list.")
            } else {
                throw ListError.creationFailed("Failed to create a new list.")
            }
        }
        let newUserList = UserList(id: listId, name: listName)
        try await UserManager.shared.createNewList(
            userId: currentUser.userId, newList: newUserList)
        try await loadLists()
    }

    func addCategory(name newCategoryName: String, to listId: String)
        async throws
    {
        let category = DBCategory(name: newCategoryName)
        try await ListManager.shared
            .addCategory(to: listId, category: category)
    }

    func addItem(item: DBItem, to categoryId: String, in listId: String)
        async throws
    {
        try await ListManager.shared
            .addItem(to: listId, categoryId: categoryId, item: item)
    }

    // Delete functions

    func deleteList(id: String) async throws {
        guard let currentUser else {
            throw UserError.notLoggedIn(
                "User must be logged in.")
        }

        try await UserManager.shared.deleteList(
            userId: currentUser.userId, listId: id)
        try await ListManager.shared.deleteList(
            listId: id, userId: currentUser.userId)
        try await loadLists()
    }

    func deleteCategory(listId: String, categoryId: String) async throws {
        try await ListManager.shared.deleteCategory(
            listId: listId, categoryId: categoryId)
    }

    func deleteItem(listId: String, categoryId: String, item: DBItem)
        async throws
    {
        try await ListManager.shared.deleteItem(
            listId: listId, categoryId: categoryId, item: item)
    }

    func deleteCheckedItems(listId: String) async throws {
        guard var list = currentList else {
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

        list.categories = updatedCategories

        try await ListManager.shared
            .updateCategories(
                listId: listId,
                updatedCategories: list.categories
            )
    }

    func deleteItems() async throws {
        guard let list = currentList, let category = currentCategory else {
            return
        }

        try await ListManager.shared.updateCategoryItems(
            listId: list.listId, categoryId: category.id, with: [])
    }

    // Update functions

    func updateListName(list: DBList) async throws {
        guard let currentUser else {
            throw UserError.notLoggedIn(
                "User must be logged in.")
        }
        try await UserManager.shared.updateListName(
            userId: currentUser.userId, listId: list.listId, listName: list.name
        )
        try await ListManager.shared.updateListName(
            listId: list.listId, listName: list.name)
        //        try await loadCurrentUser()
        try await loadLists()
    }

    func updateCategoryName(
        listId: String, categoryId: String, categoryName: String
    ) async throws {
        try await ListManager.shared
            .updateCategoryName(
                listId: listId,
                categoryId: categoryId,
                categoryName: categoryName
            )
    }

    //    func moveList(from source: IndexSet, to destination: Int) async throws {
    //        guard var user = currentUser else {
    //            throw UserError.notLoggedIn("User must be logged in to move lists.")
    //        }
    //        guard var DBLists = lists else {
    //            throw ListError.updateFailed("Unable to retrieve lists.")
    //        }
    //
    //        DBLists.move(fromOffsets: source, toOffset: destination)
    //        user.lists.move(fromOffsets: source, toOffset: destination)
    //
    //        try await UserManager.shared.updateLists(
    //            userId: user.userId,
    //            updatedLists: user.lists
    //        )
    //
    //        self.lists = DBLists
    //
    //        print("DBLISTS", DBLists)
    //        print("USER.LISTS", user.lists)
    //    }

    func updateItemOrder(
        listId: String, categoryId: String, updatedItems: [DBItem]
    ) async throws {
        try await ListManager.shared.updateCategoryItems(
            listId: listId, categoryId: categoryId, with: updatedItems)
    }

    func updateCategoryOrder() async throws {
        guard let list = currentList else { return }
        try await ListManager.shared
            .updateCategories(
                listId: list.listId, updatedCategories: list.categories)
    }

    func moveCategoryUp(category: DBCategory) async throws {
        guard var list = currentList else { return }
        guard
            let index = list.categories.firstIndex(where: {
                $0.id == category.id
            }), index > 0
        else {
            return
        }

        list.categories.swapAt(index, index - 1)
        currentList = list
        //        try await updateCategoryOrder(
        //            listId: list.listId, updatedCategories: list.categories)
    }

    func moveCategoryDown(category: DBCategory) async throws {
        guard var list = currentList else { return }
        guard
            let index = list.categories.firstIndex(where: {
                $0.id == category.id
            }),
            index < (list.categories.count) - 1
        else {
            return
        }
        list.categories.swapAt(index, index + 1)
        currentList = list
        //        try await updateCategoryOrder(
        //            listId: list.listId, updatedCategories: list.categories)
    }

    //

    func toggleItem(listId: String, categoryId: String, item: DBItem)
        async throws
    {
        try await ListManager.shared.toggleCheckedItem(
            listId: listId, categoryId: categoryId, item: item)
    }

    func toggleCategoryOpen(categoryId: String) {
        categoryOpenState[categoryId, default: true].toggle()
    }

    func isCategoryOpen(categoryId: String) -> Bool {
        return categoryOpenState[categoryId] ?? true
    }

    func acceptList(listId: String, listName: String, userId: String)
        async throws
    {
        try await ListManager.shared.addUser(listId: listId, userId: userId)
        try await UserManager.shared.addSharedList(
            listId: listId, listName: listName, userId: userId)
        try await UserManager.shared.removePendingList(
            listId: listId, userId: userId)
        try await loadLists()
    }

    func declineList(listId: String, userId: String) async throws {
        try await UserManager.shared.removePendingList(
            listId: listId, userId: userId)
        //        try await loadCurrentUser()
    }

}

struct HomeView: View {
    @Binding var showSignInView: Bool
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @State var activeSheet: SheetType?
    @State private var isLoading: Bool = true
    @State private var didAppear: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceBackground.ignoresSafeArea()
                if viewModel.lists != nil, !isLoading {
                    listsView
                }
                addListButton
            }
        }
        .padding(.top, 48)
        .task {
            if viewModel.currentUser == nil {
                try? await viewModel.loadCurrentUser()
                try? await viewModel.loadLists()
                if let user = viewModel.currentUser, !didAppear {
                    viewModel.addUserListener(userId: user.userId)
                    didAppear = true
                }
                withAnimation { isLoading = false }
            }
        }
        .overlay {
            MainNavBar(
                title: "Lists",
                pendingListsCount: viewModel.currentUser?.pendingLists.count
                    ?? 0,
                showSignInView: $showSignInView,
                activeSheet: $activeSheet
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addingList:
                ListSheet(
                    list: DBList.defaultNewList(),
                    dismissAction: { activeSheet = nil }
                ).environmentObject(viewModel)

            case .editingList:
                if let list = viewModel.currentList,
                    let user = viewModel.currentUser
                {
                    EditListContainer(
                        list: list,
                        currentUserEmail: user.email,
                        dismissAction: { activeSheet = nil }
                    )
                    .environmentObject(viewModel)
                }

            case .pendingList:
                if let user = viewModel.currentUser {
                    PendingSheet(
                        user: user,
                        dismissAction: { activeSheet = nil }
                    )
                    .environmentObject(viewModel)
                }

            case .addingCategory:
                if let list = viewModel.currentList {
                    CategorySheet(
                        category: DBCategory.defaultNewCategory(),
                        listId: list.listId,
                        dismissAction: { activeSheet = nil }
                    ).environmentObject(
                        viewModel
                    )
                }

            case .addingItem:
                if let list = viewModel.currentList {
                    EditItemContainer(
                        item: DBItem.defaultNewItem(),
                        categories: list.categories,
                        listId: list.listId,
                        dismissAction: { activeSheet = nil }
                        // viewModel.setCurrentItem(item: nil)
                    ).environmentObject(viewModel)
                }

            case .editingCategory:
                if let category = viewModel.currentCategory,
                    let list = viewModel.currentList
                {
                    CategorySheet(
                        category: category,
                        listId: list.listId,
                        isEditing: true,
                        dismissAction: { activeSheet = nil }
                    ).environmentObject(
                        viewModel
                    )
                }

            case .editingItem:
                if let item = viewModel.currentItem,
                    let list = viewModel.currentList
                {
                    EditItemContainer(
                        item: item,
                        categories: list.categories,
                        listId: list.listId,
                        isEditing: true,
                        dismissAction: { activeSheet = nil }
                    ).environmentObject(viewModel)
                }

            case .shareList:
                if let list = viewModel.currentList,
                    let user = viewModel.currentUser
                {
                    ShareSheet(
                        list: list,
                        sender: user.displayName,
                        dismissAction: { activeSheet = nil }
                    )
                }

            case .renameList:
                if let list = viewModel.currentList {
                    ListSheet(
                        list: list,
                        isEditing: true,
                        dismissAction: { activeSheet = nil }
                    ).environmentObject(viewModel)
                }

            case .deleteList:
                if let list = viewModel.currentList {
                    ConfirmSheet(
                        heading: "Delete list",
                        text: "Do you want to delete \(list.name)?",
                        dismissAction: { activeSheet = nil },
                        confirmAction: {
                            try await viewModel.deleteList(id: list.listId)
                            activeSheet = nil
                        }
                    )
                }

            case .renameCategory:
                if let category = viewModel.currentCategory,
                    let list = viewModel.currentList
                {
                    CategorySheet(
                        category: category,
                        listId: list.listId,
                        isEditing: true,
                        dismissAction: { activeSheet = nil }
                    ).environmentObject(
                        viewModel
                    )
                }

            case .deleteCategory:
                if let category = viewModel.currentCategory,
                    let list = viewModel.currentList
                {
                    ConfirmSheet(
                        heading: "Delete category",
                        text:
                            "Are you sure you'd like to delete \(category.name)?",
                        dismissAction: { activeSheet = nil },
                        confirmAction: {
                            try await viewModel
                                .deleteCategory(
                                    listId: list.listId,
                                    categoryId: category.id)
                            activeSheet = nil
                        }
                    )
                }

            }
        }
    }

    private var addListButton: some View {
        VStack {
            Spacer()
            Button(action: {
                withAnimation {
                    activeSheet = .addingList
                }
            }) {
                Label("List", systemImage: "plus")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.content)
                    .padding(.horizontal, Padding.gutter)
                    .padding(.vertical, Padding.regular)
                    .frame(
                        alignment: .center
                    )
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(Color(.surface))
                            .shadow(
                                color: .black.opacity(0.2), radius: 2,
                                x: 0,
                                y: 2)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(Padding.gutter)
    }

    private var listsView: some View {
        if let lists = viewModel.lists, !lists.isEmpty {
            return AnyView(
                List {
                    ForEach(lists, id: \.listId) { list in
                        listView(list: list)
                            .listRowInsets(EdgeInsets())
                    }
                    //                    .onMove(perform: moveList)
                    .listRowSeparator(.hidden)
                    .foregroundStyle(Color.content)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: CornerRadius.regular)
                            .fill(Color(.surface))
                            .padding(.vertical, Padding.tiny)
                    )

                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(.compact)
                .environment(\.defaultMinListRowHeight, 0)
                .listStyle(.insetGrouped)
            )
        } else {
            return AnyView(
                List {
                    VStack(alignment: .leading) {
                        Text(
                            "Add a list by tapping the button in the bottom right corner."
                        )
                        .padding(.horizontal, Padding.gutter)
                        .padding(.vertical, Padding.regular)
                        .font(.caption)
                    }
                    .listRowInsets(EdgeInsets())
                    .foregroundStyle(Color.contentFaded)
                }
                .listSectionSpacing(.compact)
                .environment(\.defaultMinListRowHeight, 0)
                .listStyle(.insetGrouped)
            )
        }
    }

    private func listView(list: DBList) -> some View {
        HStack(spacing: Padding.regular) {
            ZStack {
                NavigationLink(
                    destination:
                        ListView(list: list, activeSheet: $activeSheet)
                        .environmentObject(viewModel)
                ) {
                    EmptyView()
                }
                .opacity(0)
                Text(list.name)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Menu {
                Button(action: {
                    viewModel.setCurrentList(list: list)
                    activeSheet = .renameList
                }) {
                    Label(
                        "Rename list",
                        systemImage: "square.and.pencil")
                }
                Button(action: {
                    viewModel.setCurrentList(list: list)
                    activeSheet = .shareList
                }) {
                    Label(
                        "Share list",
                        systemImage: "paperplane")
                }
                Button(action: {
                    viewModel.setCurrentList(list: list)
                    activeSheet = .deleteList
                }) {
                    Label(
                        "Delete list",
                        systemImage: "minus.circle")
                }
            } label: {
                Label("Options", systemImage: "ellipsis")
                    .foregroundStyle(Color.surfaceLight)
                    .labelStyle(.iconOnly)
                    .frame(width: 24, height: 24, alignment: .center)
            }
        }
        .listRowSeparator(.hidden)
        .foregroundStyle(Color.content)
        .padding(Padding.regular)
    }
}
