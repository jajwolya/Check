//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct NavigationBarList: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: ListViewModel
    var title: String
    var displayShare: Bool = false
    @Binding var isAdding: Bool
    @Binding var isSharing: Bool
    var listId: String

    var body: some View {
        ZStack {
            Color(.surfaceBackground).ignoresSafeArea()
            HStack {
                HStack(spacing: Padding.large) {
                    if presentationMode.wrappedValue.isPresented {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.backward")
                        }
                    }
                    Text(title)
                        .font(.title3.weight(.bold))

                }.frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: Padding.regular) {
                    Menu {
                        Button(action: { isAdding = true }) {
                            Label("Add category", systemImage: "folder.badge.plus")
                        }
                        Button(action: { isSharing = true }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.deleteCheckedItems(
                                        listId: listId)
                                }
                            }
                        }) {
                            Label("Remove checked items", systemImage: "minus.circle")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(width: 32, height: 32, alignment: .center)
                            .background(Circle().fill(Color.surface))
                    }
                }.frame(alignment: .trailing)

            }.foregroundStyle(Color.white).padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    NavigationBar(title: "Title")
//}
