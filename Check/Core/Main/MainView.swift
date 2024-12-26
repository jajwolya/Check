//
//  ProfileView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import SwiftUI

@MainActor final class MainViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var lists: [DBList]? = []

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared
            .getAuthenticatedUser()
        self.user = try await UserManager.shared
            .getUser(userId: authDataResult.uid)
    }
    
//    func loadLists() async throws {
//        guard let user = user else {
//            throw UserError.notLoggedIn("User must be logged in to load lists.")
//        }
//        // Assuming user.lists contains the list IDs or List objects.
//        let userLists = try await UserManager.shared.getUser(userId: user.userId).lists
//        // Fetch each list and add it to your `lists` array
//        var dbLists: [DBList] = []
//        for list in userLists {
//            let dbList = try await ListManager.shared.getList(listId: list.id)
//            dbLists.append(dbList)
//        }
//        self.lists = dbLists
//    }

    func addNewList(newListName: String) async throws {
        guard let user,
            let listId = try? await ListManager.shared.createNewList(
                name: newListName, userId: user.userId)
        else {
            if user == nil {
                throw UserError.notLoggedIn(
                    "User must be logged in to create a list.")
            } else {
                throw ListError.creationFailed("Failed to create a new list.")
            }
        }
        let newList = UserList(name: newListName, id: listId)
        try await UserManager.shared.createNewList(
            userId: user.userId, newList: newList)
//        updateUserLists(with: newList)
        try await loadCurrentUser()
    }

    func deleteList(id: String) async throws {
        guard let user else {
            throw UserError.notLoggedIn(
                "User must be logged in.")
        }

        try await UserManager.shared.deleteList(
            userId: user.userId, listId: id)
        try await ListManager.shared.deleteList(
            listId: id, userId: user.userId)
//        removeUserList(with: id)
        try await loadCurrentUser()
    }
}

struct ProfileView: View {
    enum FocusedField: Hashable {
        case newListName
    }

    @StateObject private var viewModel: MainViewModel = MainViewModel()
    @Binding var showSignInView: Bool
    @FocusState private var focusedField: FocusedField?
    @State private var isAddingList: Bool = false
    @State private var openPendingLists: Bool = false
    @State var newListName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.surfaceBackground)
                    .ignoresSafeArea()
                List {
                    if let lists = viewModel.user?.lists, !lists.isEmpty {
                        listsView(lists: lists)
                    }

                    if isAddingList {
                        newListView
                            .focused($focusedField, equals: .newListName)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.surfaceBackground))
                .padding(.top, 48)
            }
            .overlay(
                NavigationBar(
                    title: "Check",
                    pendingListsCount: viewModel.user?.pendingLists.count ?? 0,
                    showSignInView: $showSignInView,
                    isAdding: $isAddingList,
                    openPendingLists: $openPendingLists
                )
            )
            .task {
                await loadUser()
            }
            .sheet(isPresented: $openPendingLists) {
                if let user = viewModel.user {
                    PendingSheet(isPresented: $openPendingLists, user: user)
                }
            }
        }
    }

    private func loadUser() async {
        if viewModel.user == nil {
            do {
                try await viewModel.loadCurrentUser()
            } catch {
                print("Failed to load current user: \(error)")
            }
        }
    }

    private func listsView(lists: [UserList]) -> some View {
        ForEach(lists, id: \.id) { list in
            NavigationLink(destination: ListView(listId: list.id, listName: list.name)) {
                Text(list.name)
            }
            .swipeActions {
                Button(
                    role: .destructive,
                    action: {
                        Task {
                            do {
                                try await viewModel.deleteList(id: list.id)
                            } catch {
                                print("Error deleting list: \(error)")
                            }
                        }
                    }
                ) {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.alert)
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.surface))
                .padding(.vertical, Padding.tiny)
                .shadow(
                    color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        )
        .font(.body)
        .padding(.vertical, Padding.small)
        .listRowSeparator(.hidden)
        .foregroundStyle(.white)

    }

    private var newListView: some View {
            TextField(
                "",
                text: $newListName,
                prompt: Text("List name")
                    .foregroundColor(.surfaceLight)
            )
            .onSubmit {
                Task {
                    do {
                        try await viewModel.addNewList(newListName: newListName)
                        isAddingList = false
                        newListName = ""
                    } catch {
                        print("Error creating list: \(error)")
                    }
                }
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.surface))
                    .padding(.vertical, Padding.tiny)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            )
            .font(.body)
            .padding(.vertical, Padding.small)
            .listRowSeparator(.hidden)
            .foregroundStyle(.white)
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
