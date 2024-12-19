//
//  ShareSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

@MainActor final class ShareSheetViewModel: ObservableObject {
    func shareList(listId: String, with email: String) async throws {
        guard let user = try await UserManager.shared.getUserByEmail(email: email) else {
            throw UserError.noCurrentUser(
                "No user with that email could be found.")
        }

        let userId = user.userId
        try await UserManager.shared.addSharedList(listId: listId, userId: userId)
        try await ListManager.shared.addUser(listId: listId, userId: userId)
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
            VStack {
                TextField(
                    "",
                    text: $emailToShare,
                    prompt: Text("Email")
                        .foregroundColor(.surfaceLight)
                )
                .onSubmit {
                    Task {
                        do {
                            try await viewModel.shareList(listId: listId, with: emailToShare)
                            isSharing = false
                        } catch {
                            print("Could not share list: \(error)")
                        }
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
                .background(Color(.surface))
            }
            .padding(.horizontal, Padding.gutter)
        }

    }
}

//#Preview {
//    ShareSheet()
//}
