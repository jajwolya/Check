//
//  ProfileView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import SwiftUI

@MainActor final class ProfileViewModel: ObservableObject {

    @Published private(set) var user: DBUser? = nil
    @Published private(set) var lists: [DBList] = []

    @Published var newListName: String = ""

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared
            .getAuthenticatedUser()
        self.user = try await UserManager.shared
            .getUser(userId: authDataResult.uid)
    }

    func loadLists() async throws {
        guard let user else {
            throw UserError.notLoggedIn(
                "User must be logged in to create a list.")
        }
        self.lists = try await UserManager.shared
            .getLists(userId: user.userId)
    }

    func addNewList() async throws {
        guard let user,
            let listId = try? await ListManager.shared.createNewList(
                name: newListName)
        else {
            if user == nil {
                throw UserError.notLoggedIn(
                    "User must be logged in to create a list.")
            } else {
                throw ListError.creationFailed("Failed to create a new list.")
            }
        }
        try await UserManager.shared.createNewList(
            userId: user.userId, listId: listId)
        self.lists = try await UserManager.shared.getLists(userId: user.userId)
    }

    func deleteList(at offsets: IndexSet) async throws {
        guard let user else {
            throw UserError.notLoggedIn(
                "User must be logged in to create a list.")
        }
        
        for index in offsets {
            let listIdToDelete = lists[index].listId
            try await UserManager.shared.deleteList(
                userId: user.userId, listId: listIdToDelete)
            try await ListManager.shared.deleteList(listId: listIdToDelete)
        }
        
        self.lists = try await UserManager.shared.getLists(userId: user.userId)
    }
}

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isAddingList: Bool = false

    var body: some View {
        List {
            if !viewModel.lists.isEmpty {
                ForEach(viewModel.lists, id: \.listId) { list in
                    NavigationLink(destination: ListView(listId: list.listId)) {
                        Text(list.name)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        do {
                            try await viewModel.deleteList(at: indexSet)
                        } catch {
                            print("Error deleting list: \(error)")
                        }
                    }
                }
            } else {
                Text("Add a list to get started!")
            }
            if viewModel.user != nil {
                if isAddingList {
                    NewListView
                }
            }
        }
        .task {
            do {
                try await viewModel.loadCurrentUser()
                try await viewModel.loadLists()
            } catch {
                print("Failed to load current user or lists: \(error)")
            }
        }
        .navigationTitle("Lists")
        .toolbar { toolbarContent }
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(
                    destination: SettingsView(showSignInView: $showSignInView)
                ) {
                    Image(systemName: "ellipsis")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    //                    newCategoryName = ""
                    //                    isAddingCategory = true
                    isAddingList = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var NewListView: some View {
        TextField(
            "New list name",
            text: $viewModel.newListName,
            onCommit: {
                Task {
                    do {
                        try await viewModel.addNewList()
                        isAddingList = false
                    } catch {
                        print("Error creating list: \(error)")
                    }
                }
            })
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
