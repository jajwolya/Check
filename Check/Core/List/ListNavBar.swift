//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct ListNavBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: HomeViewModel
    let list: DBList

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
                    
                    Text(list.name)
                        .font(.title3.weight(.bold))
                }.frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: Padding.regular) {
                    if viewModel.isReorderingCategories {
                        Button(
                            action: {
                                viewModel.toggleReorderingCategories()
                                Task {
                                    do {
                                        try await viewModel.updateCategoryOrder()
                                    }
                                }
                            }
                        ) {
                            Text("Done")
                        }
                    } else {
                        Menu {
                            Button(action: {
                                Task {
                                    do {
                                        try await viewModel.deleteCheckedItems(
                                            listId: list.listId)
                                    }
                                }
                            }) {
                                Label(
                                    "Remove checked items",
                                    systemImage: "arrow.clockwise")
                            }
                            Button(action: {
                                viewModel.toggleReorderingCategories()
                            }) {
                                Label(
                                    "Reorder categories",
                                    systemImage: "arrow.trianglehead.swap")
                            }
                        } label: {
                            Label("Options", systemImage: "ellipsis")
                                .labelStyle(.iconOnly)
                                .frame(
                                    width: 32, height: 32, alignment: .center)
                        }
                    }
                }.frame(alignment: .trailing)
            }
            .foregroundStyle(Color.content)
            .padding(.horizontal, Padding.gutter)
            
            VStack {
                Spacer()
                Divider().background(Color.surfaceLight)
            }
            .padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    NavigationBar(title: "Title")
//}
