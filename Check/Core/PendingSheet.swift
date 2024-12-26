//
//  PendingSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 23/12/2024.
//

import SwiftUI

@MainActor final class PendingSheetViewModel: ObservableObject {
    func acceptList(listId: String, userId: String) async throws {
        try await UserManager.shared.addSharedList(
            listId: listId, userId: userId)
        try await UserManager.shared.removePendingList(
            listId: listId, userId: userId)
    }

    func declineList(listId: String, userId: String) async throws {
        try await UserManager.shared.removePendingList(
            listId: listId, userId: userId)
    }
}

struct PendingSheet: View {
    @StateObject var viewModel: PendingSheetViewModel = PendingSheetViewModel()
    @Binding var isPresented: Bool
    let user: DBUser

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                if(!user.pendingLists.isEmpty){
                    ForEach(user.pendingLists, id: \.listId) { list in
                        pendingListRow(list: list)
                    }
                } else {
                    Text("No pending requests!")
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Padding.gutter)
            .padding(.vertical, Padding.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.fraction(0.5), .large])
        .presentationBackground(.ultraThinMaterial)
    }

    private func pendingListRow(list: PendingList) -> some View {
        HStack(spacing: Padding.small) {
            VStack(alignment: .leading, spacing: Padding.small) {
                Text(list.listName)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("from \(list.sender)")
                    .font(.subheadline)
                    .foregroundStyle(Color.surfaceLight)
            }
            Spacer()
            Button(
                action: {
                    Task {
                        do {
                            try await viewModel.declineList(
                                listId: list.listId,
                                userId: user.userId
                            )
                        }
                    }
                }) {
                    Image(systemName: "x.circle.fill")
                }
            Button(action: {
                Task {
                    do {
                        try await viewModel.acceptList(
                            listId: list.listId,
                            userId: user.userId)
                    }
                }
            }) {
                Image(systemName: "checkmark.circle.fill")
            }
        }
        .padding(Padding.regular)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.surface))
    }
}

//#Preview {
//    PendingSheet()
//}
