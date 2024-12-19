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
                name: newListName, userId: user.userId)
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

    func deleteList(_ listId: String) async throws {
        guard let user else {
            throw UserError.notLoggedIn(
                "User must be logged in.")
        }

        try await UserManager.shared.deleteList(
            userId: user.userId, listId: listId)
        try await ListManager.shared.deleteList(
            listId: listId, userId: user.userId)
        self.lists = try await UserManager.shared.getLists(userId: user.userId)
    }
}

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isAddingList: Bool = false

    var body: some View {
        ZStack {
            Color(.surfaceDark)
                .ignoresSafeArea()
            List {
                if !viewModel.lists.isEmpty {
                    listsView()
                }

                if viewModel.user != nil {
                    if isAddingList {
                        newListView
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.surfaceDark))
            .padding(.top, 48)
        }
        .overlay(
            NavigationBar(title: "Lists")
        )
        .task {
            do {
                try await viewModel.loadCurrentUser()
                try await viewModel.loadLists()
            } catch {
                print("Failed to load current user or lists: \(error)")
            }
        }
        .toolbar { toolbarContent }
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(
                    destination: SettingsView(showSignInView: $showSignInView)
                ) {
                    Image(systemName: "ellipsis").foregroundStyle(Color.white)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isAddingList = true
                }) {
                    Image(systemName: "plus")
                    .padding(Padding.tiny)
                    .foregroundStyle(Color.white)
                    .background(
                        Circle().fill(Color.surface).shadow(
                            color: .black.opacity(0.2), radius: 2, x: 0, y: 2))
                }
            }
        }
    }

    private func listsView() -> some View {
        ForEach(viewModel.lists, id: \.listId) { list in
            NavigationLink(destination: ListView(listId: list.listId)) {
                Text(list.name)
            }
            .swipeActions{
                Button(
                    role: .destructive,
                    action: {
                        Task {
                            do {
                                try await viewModel.deleteList(list.listId)
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
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        )
        .font(.body)
        .padding(.vertical, Padding.small)
        .listRowSeparator(.hidden)
        .foregroundStyle(.white)

    }

    private var newListView: some View {
        withAnimation {
            TextField(
                "",
                text: $viewModel.newListName,
                prompt: Text("List name")
                    .foregroundColor(.surfaceLight)
            )
            .onSubmit {
                Task {
                    do {
                        try await viewModel.addNewList()
                        isAddingList = false
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
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
