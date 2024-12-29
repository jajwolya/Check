//
//  ProfileView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import SwiftUI

@MainActor final class MainViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    //    @Published private(set) var lists: [DBList]? = []

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

    func addNewList(listName: String) async throws {
        guard let user,
            let listId = try? await ListManager.shared.createNewList(
                name: listName, userId: user.userId)
        else {
            if user == nil {
                throw UserError.notLoggedIn(
                    "User must be logged in to create a list.")
            } else {
                throw ListError.creationFailed("Failed to create a new list.")
            }
        }
        let newList = UserList(name: listName, id: listId)
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

    func updateListName(listId: String, listName: String) async throws {
        guard let user else {
            throw UserError.notLoggedIn(
                "User must be logged in.")
        }
        try await UserManager.shared.updateListName(
            userId: user.userId, listId: listId, listName: listName)
        try await ListManager.shared.updateListName(
            listId: listId, listName: listName)
        try await loadCurrentUser()
    }
}

struct ProfileView: View {
    enum FocusedField: Hashable {
        case list
    }

    @StateObject private var viewModel: MainViewModel = MainViewModel()
    @Binding var showSignInView: Bool
    @FocusState private var focusedField: FocusedField?
    @State private var isAddingList: Bool = false
    @State private var openPendingLists: Bool = false
    @State private var isEditingList: Bool = false
    @State var listName: String = ""
    @State var listBeingEdited: String?

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
                            .focused($focusedField, equals: .list)
                            .onAppear {
                                focusedField = .list
                            }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.surfaceBackground))
                .padding(.top, 48)
            }
            .overlay {
                NavigationBar(
                    title: "Check",
                    pendingListsCount: viewModel.user?.pendingLists.count ?? 0,
                    showSignInView: $showSignInView,
                    isAdding: $isAddingList,
                    listName: $listName,
                    openPendingLists: $openPendingLists,
                    isEditingList: $isEditingList
                )
            }
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
            HStack(spacing: Padding.regular) {
                if !isEditingList || list.id != listBeingEdited {
                    ZStack {
                        NavigationLink(
                            destination: ListView(
                                listId: list.id, listName: list.name)
                        ) {
                            EmptyView()
                        }.opacity(0)
                        Text(list.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: {
                        isEditingList = true
                        listBeingEdited = list.id
                        listName = list.name
                        isAddingList = false
                    }) {
                        Label("Edit", systemImage: "ellipsis")
                            .foregroundStyle(Color.surfaceLight)
                            .labelStyle(.iconOnly)
                            .frame(width: 24, height: 24, alignment: .center)
                    }.buttonStyle(.borderless)
                } else {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.deleteList(id: list.id)
                                isEditingList = false
                                listBeingEdited = nil
                            } catch {
                                print("Error deleting list: \(error)")
                            }
                        }
                    }) {
                        Label("Delete", systemImage: "minus")
                            .foregroundStyle(Color.white)
                            .labelStyle(.iconOnly)
                    }
                    .frame(width: 24, height: 24, alignment: .center)
                    .background(Circle().fill(Color.alert))
                    TextField(
                        "\(list.name)",
                        text: $listName,
                        prompt: Text("List name")
                            .foregroundColor(.surfaceLight)
                    )
                    .focused($focusedField, equals: .list)
                    .onAppear {
                        focusedField = .list
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        Task {
                            if !listName.isEmpty {
                                do {
                                    try await viewModel.updateListName(
                                        listId: list.id, listName: listName)
                                    isEditingList = false
                                    listBeingEdited = nil
                                    listName = ""
                                } catch {
                                    print("Error updating list: \(error)")
                                }
                            }
                        }
                    }
                    Button(action: {
                        isEditingList = false
                        listBeingEdited = nil
                    }){
                        Text("Cancel")
                    }
                    .foregroundStyle(Color.surfaceLight)
                    .buttonStyle(.borderless)
                }

                //                Button(action: {}){
                //                    Image(systemName: "ellipsis").foregroundStyle(Color.surfaceLight)
                //                }.buttonStyle(.borderless)
            }

            //            .swipeActions {
            //                Button(
            //                    role: .destructive,
            //                    action: {
            //                        Task {
            //                            do {
            //                                try await viewModel.deleteList(id: list.id)
            //                            } catch {
            //                                print("Error deleting list: \(error)")
            //                            }
            //                        }
            //                    }
            //                ) {
            //                    Label("Delete", systemImage: "trash")
            //                }
            //                .tint(.alert)
            //            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.surface))
                .padding(.vertical, Padding.small)
                .shadow(
                    color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        )
        .font(.body)
        .padding(.vertical, Padding.regular)
        .listRowSeparator(.hidden)
        .foregroundStyle(.white)

    }

    private var newListView: some View {
        TextField(
            "",
            text: $listName,
            prompt: Text("List name")
                .foregroundColor(.surfaceLight)
        )
        .submitLabel(.done)
        .onSubmit {
            Task {
                if !listName.isEmpty {
                    do {
                        try await viewModel.addNewList(listName: listName)
                        isAddingList = false
                        listName = ""
                    } catch {
                        print("Error creating list: \(error)")
                    }
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
