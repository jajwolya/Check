//
//  PendingSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 23/12/2024.
//

import SwiftUI

struct PendingSheet: View {
    @EnvironmentObject var viewModel: HomeViewModel
    let user: DBUser
    let dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                if !user.pendingLists.isEmpty {
                    ForEach(user.pendingLists, id: \.id) { list in
                        pendingList(list: list)
                    }
                } else {
                    Text("No pending requests!")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                }
            }
            .foregroundStyle(Color.content)
            .padding(.horizontal, Padding.gutter)
            .padding(.vertical, Padding.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.fraction(0.5), .large])
        .presentationBackground(.ultraThinMaterial)
    }

    private func pendingList(list: PendingList) -> some View {
        VStack(spacing: Padding.regular) {
            HStack(spacing: Padding.regular) {
                Text(list.name)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.content)
                Spacer()
                Text("from \(list.sender)")
                    .font(.subheadline)
                    .foregroundStyle(Color.surfaceLight)
            }
            HStack(spacing: Padding.regular) {
                Button(
                    action: {
                        Task {
                            do {
                                try await viewModel.declineList(
                                    listId: list.id,
                                    userId: user.userId
                                )
                                dismissAction()
                            }
                        }
                    }) {
                        Text("Decline")
                            .foregroundStyle(Color.content)
                            .padding(Padding.small)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: CornerRadius.medium
                                )
                                .fill(Color.surfaceDark)
                            )

                    }
                Button(action: {
                    Task {
                        do {
                            try await viewModel.acceptList(
                                listId: list.id,
                                listName: list.name,
                                userId: user.userId)
                            dismissAction()
                        }
                    }
                }) {
                    Text("Accept")
                        .foregroundStyle(Color.surfaceBackground)
                        .padding(Padding.small)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.light)
                        )
                }

            }
        }
        .padding(Padding.regular)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.regular)
                .fill(Color.surface)
        )
    }
}

//#Preview {
//    PendingSheet()
//}
