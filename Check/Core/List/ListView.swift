//
//  ListView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/1/2025.
//

import SwiftUI

struct ListView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var viewModel: HomeViewModel
    var list: DBList
    @Binding var activeSheet: SheetType?
    @State private var showEditMenu: Bool = false
    @State private var didAppear: Bool = false

    var body: some View {
        ZStack {
            List {
                if let categories = viewModel.currentList?.categories,
                    !categories.isEmpty
                {
                    Spacer().frame(maxHeight: 0)
                        .listRowBackground(Color.clear)
                    ForEach(categories) { category in
                        CategoryView(
                            list: viewModel.currentList!,
                            category: category,
                            activeSheet: $activeSheet
                        )
                        .environmentObject(viewModel)
                        .listRowInsets(EdgeInsets())
                    }
                    Spacer().frame(height: 64)
                        .listRowBackground(Color.clear)
                } else {
                    emptyListView
                }
            }
            .listSectionSpacing(.compact)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.insetGrouped)
            .onAppear {
                if let list = viewModel.currentList, !didAppear {
                    viewModel.addListListener(listId: list.listId)
                    didAppear = true
                }
            }
            .refreshable {
                if let list = viewModel.currentList {
                    try? await viewModel.deleteCheckedItems(
                        listId: list.listId)
                }
            }
        }
        .padding(.top, 24)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if let list = viewModel.currentList {
                ListNavBar(
                    list: list
                ).environmentObject(viewModel)
            }
            addCategoryButton
            //            editMenu()
        }
        .onAppear {
            viewModel.setCurrentList(list: list)
            viewModel.setCurrentCategory(category: list.categories.first)
        }
    }

    private var emptyListView: some View {
        VStack(alignment: .leading) {
            Text("Add a category by tapping the button in the bottom right corner.")
                .font(.caption)
        }
        .padding(.horizontal, Padding.gutter)
        .padding(.vertical, Padding.regular)
        .listRowInsets(EdgeInsets())
        .foregroundStyle(Color.contentFaded)
    }

    private var addCategoryButton: some View {
        ZStack {
            if showEditMenu {
                Color(.black)
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showEditMenu = false
                        }
                    }
            }
            VStack {
                Spacer()

                Button(action: {
                    withAnimation {
                        activeSheet = .addingCategory
                    }
                }) {
                    Label("Category", systemImage: "plus")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.light)
                        .padding(.horizontal, Padding.gutter)
                        .padding(.vertical, Padding.regular)
                        .frame(
                            alignment: .center
                        )
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color(.surface))
                                .shadow(
                                    color: .black.opacity(0.2), radius: 2,
                                    x: 0,
                                    y: 2)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(Padding.gutter)
        }
    }

    private func editMenu() -> some View {
        ZStack {
            if showEditMenu {
                Color(.black)
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showEditMenu = false
                        }
                    }
            }
            VStack {
                Spacer()
                if showEditMenu {
                    VStack(alignment: .trailing, spacing: Padding.regular) {
                        Button(action: {
                            activeSheet = .addingCategory
                            withAnimation { showEditMenu = false }
                        }) {
                            Label(
                                "Add category", systemImage: "folder.badge.plus"
                            ).padding(Padding.regular)
                                .foregroundStyle(Color.light).background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(Color.surface)
                                )
                        }

                        Button(action: {
                            activeSheet = .addingItem
                            withAnimation { showEditMenu = false }
                        }) {
                            Label(
                                "Add item", systemImage: "plus.circle"
                            ).padding(Padding.regular)
                                .foregroundStyle(Color.light).background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(Color.surface)
                                )
                        }
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            showEditMenu.toggle()
                        }
                    }) {
                        AddButtonLabel()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(Padding.gutter)
        }

    }

//    private func moveCategories(indexSet: IndexSet, destination: Int) {
//        Task {
//            do {
//                try await moveCategoriesInList(
//                    indexSet: indexSet, destination: destination)
//            } catch {
//                print("Error moving categories: \(error)")
//            }
//        }
//    }
//
//    private func moveCategoriesInList(indexSet: IndexSet, destination: Int)
//        async throws
//    {
//        guard let list = viewModel.currentList else { return }
//        var categories = list.categories
//        categories.move(fromOffsets: indexSet, toOffset: destination)
//        try await viewModel.updateCategoryOrder(
//            listId: list.listId, updatedCategories: categories)
//    }
}

//#Preview {
//    NewListView()
//}
