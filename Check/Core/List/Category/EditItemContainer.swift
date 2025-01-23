//
//  EditItemContainer.swift
//  Check
//
//  Created by Jajwol Bajracharya on 10/1/2025.
//

import SwiftUI

struct EditItemContainer: View {

//    @EnvironmentObject var viewModel: ListViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State var item: DBItem
    let categories: [DBCategory]
    let listId: String
    var isEditing: Bool = false
    let dismissAction: () -> Void
    @State private var activeSheet: ActiveEditItemSheet = .item

    var body: some View {
        VStack {
            switch activeSheet {
            case .item:
                ItemSheet(
                    item: $item,
                    listId: listId,
                    isEditing: isEditing,
                    activeSheet: $activeSheet,
                    dismissAction: {
                        dismissAction()
                    }
                )
                .environmentObject(homeViewModel)

            case .categories:
                CategoriesSheet(
                    categories: categories,
                    dismissAction: { activeSheet = .item }
                ).environmentObject(homeViewModel)
            }
        }
    }
}
