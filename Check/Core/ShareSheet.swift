//
//  ShareSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

@MainActor final class ShareSheetViewModel: ObservableObject {
    func shareList(listId: String, with email: String) async throws {
        guard
            let user = try await UserManager.shared.getUserByEmail(
                email: email
            )
        else {
            throw UserError.noCurrentUser(
                "No user with that email could be found.")
        }
        
        let list = try await ListManager.shared.getList(listId: listId)

        let userId = user.userId
        //        try await UserManager.shared.addSharedList(
        //            listId: listId, userId: userId)
        //        try await ListManager.shared.addUser(listId: listId, userId: userId)
        try await UserManager.shared
            .addPendingList(
                listId: listId,
                listName: list.name,
                userId: userId,
                username: email
            )
    }
}

struct ShareSheet: View {
    @Binding var isSharing: Bool
    let listId: String

    @State private var emailToShare: String = ""
    @StateObject private var viewModel: ShareSheetViewModel =
        ShareSheetViewModel()

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                Text(
                    "Enter the email of the user you'd like to share this list with"
                ).font(.caption).foregroundStyle(.surfaceLight)
                TextField(
                    "",
                    text: $emailToShare,
                    prompt: Text("Email")
                        .foregroundColor(.surfaceLight)
                )
                .textInputAutocapitalization(.never)
                .submitLabel(.send)
                .onSubmit {
                    Task {
                        do {
                            try await viewModel.shareList(
                                listId: listId, with: emailToShare)
                            isSharing = false
                        } catch {
                            print("Could not share list: \(error)")
                        }
                    }
                }
                .padding(.vertical, Padding.small)
                .padding(.horizontal, Padding.gutter)
                .background(RoundedRectangle(cornerRadius: 8).fill(.surface))
                .font(.body)
                .listRowSeparator(.hidden)

            }
            .foregroundStyle(.white)
            .padding(.horizontal, Padding.gutter)
        }
        .presentationDetents([.fraction(0.25)])
        .presentationBackground(.ultraThinMaterial)
    }
}

//#Preview {
//    ShareSheet()
//}
