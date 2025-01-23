//
//  ShareSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

@MainActor final class ShareSheetViewModel: ObservableObject {
    @Published private(set) var users: [DBUser] = []

    func shareList(listId: String, from sender: String, to sendee: String)
        async throws
    {
        guard
            let userSendee = try await UserManager.shared.getUserByEmail(
                email: sendee
            )
        else {
            throw UserError.noCurrentUser(
                "No user with that email could be found.")
        }

        let list = try await ListManager.shared.getList(listId: listId)
        try await UserManager.shared
            .addPendingList(
                listId: listId,
                listName: list.name,
                sender: sender,
                sendee: userSendee
            )
    }

    //    func getUsers(userIds: [String]) async throws {
    //        var users: [DBUser] = []
    //        for userId in userIds {
    //            let user = try await UserManager.shared.getUser(userId: userId)
    //            users.append(user)
    //        }
    //        self.users = users
    //        print(userIds)
    //    }
}

struct ShareSheet: View {
    @StateObject private var viewModel: ShareSheetViewModel =
        ShareSheetViewModel()
    @FocusState private var emailInFocus: Bool
    @State private var sendee: String = ""

    let list: DBList
//    let list: UserList
    let sender: String
    let dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.medium) {
                Text("Share list").h3()

                TextField(
                    "",
                    text: $sendee,
                    prompt: Text("Email")
                        .foregroundColor(.surfaceLight)
                )
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .focused($emailInFocus)
                .submitLabel(.send)
                .padding(Padding.regular)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.regular)
                        .fill(.surface)
                )
                
                .onSubmit {
                    Task {
                        do {
                            try await viewModel.shareList(
                                listId: list.listId, from: sender, to: sendee)
                            dismissAction()
                        } catch {
                            print("Could not share list: \(error)")
                        }
                    }
                }

                Text(
                    "Enter the email of the user you'd like to share this list with"
                ).font(.caption).foregroundStyle(.contentFaded).frame(
                    maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack(spacing: Padding.regular) {
                    CustomButton(
                        text: "Cancel",
                        action: {
                            dismissAction()
                        },
                        variant: .secondary)
                    
                    CustomButton(
                        text: "Send",
                        action: {
                            sendAction()
                        },
                        variant: .primary)
                }

                //                Divider().background(Color.surfaceLight)

                //                VStack(spacing: Padding.small) {
                //                    Text("Currently shared with")
                //                        .font(.subheadline)
                //                        .fontWeight(.semibold)
                //                        .frame(maxWidth: .infinity, alignment: .leading)
                //
                //                    ForEach(viewModel.users, id: \.userId) { user in
                //                        Text("\(user.email)")
                //                            .font(.caption)
                //                            .fontWeight(.regular)
                //                            .frame(maxWidth: .infinity, alignment: .leading)
                //                    }
                //                }

            }
            .foregroundStyle(Color.content)
            .sheetPadding()
        }
        .onAppear {
            self.emailInFocus = true
        }
        //        .task {
        //            try? await viewModel.getUsers(userIds: list.users)
        //        }
        .presentationDetents([.fraction(0.4), .fraction(0.8)])
        .presentationBackground(.ultraThinMaterial)
    }
    
    private func sendAction() {
        Task {
            do {
                try await viewModel.shareList(
                    listId: list.listId, from: sender, to: sendee)
                dismissAction()
            } catch {
                print("Could not share list: \(error)")
            }
        }
    }
}

//#Preview {
//    ShareSheet()
//}
