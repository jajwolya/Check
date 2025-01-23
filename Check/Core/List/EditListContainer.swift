//
//  EditListContainer.swift
//  Check
//
//  Created by Jajwol Bajracharya on 11/1/2025.
//

import SwiftUI

struct EditListContainer: View {
    //    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    //    let list: UserList
    let list: DBList
    let currentUserEmail: String
    var dismissAction: () -> Void
    @State var activeSheet: ActiveEditListSheet?

    var body: some View {
        ZStack {
            Color.surfaceDark.ignoresSafeArea()

            switch activeSheet {

            case .none:
                VStack {
                    Text("\(list.name)").h3()
                    listItem(
                        text: "Share list", icon: "paperplane",
                        sheet: .shareList)
                    listItem(
                        text: "Rename list", icon: "square.and.pencil", sheet: .renameList)
                    listItem(
                        text: "Delete list", icon: "minus.circle",
                        sheet: .deleteList)
                    Spacer()
                    CustomButton(
                        text: "Cancel",
                        action: {
                            dismissAction()
                        },
                        variant: .secondary)
                }
                .sheetPadding()

            case .shareList:
                ShareSheet(
                    list: list,
                    sender: currentUserEmail,
                    dismissAction: { dismissAction() }
                )

            case .renameList:
                ListSheet(
                    list: list,
                    isEditing: true,
                    dismissAction: { dismissAction() }
                ).environmentObject(viewModel)

            case .deleteList:
                ConfirmSheet(
                    heading: "Delete list",
                    text: "Do you want to delete \(list.name)?",
                    dismissAction: { dismissAction() },
                    confirmAction: {
                        try await viewModel.deleteList(id: list.listId)
                        dismissAction()
                    }
                )
            }

        }
        .presentationDetents([.fraction(0.5), .fraction(0.8)])
        .presentationBackground(.ultraThinMaterial)
    }

    private func listItem(
        text: String, icon: String, sheet: ActiveEditListSheet
    ) -> some View {
        Button(
            action: {
                withAnimation { activeSheet = sheet }
            }) {
                HStack(spacing: Padding.regular) {
                    Text(text)
                        .foregroundStyle(Color.light)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image(systemName: icon).foregroundStyle(Color.surfaceLight)
                }
                .padding(Padding.regular)
                .background(RoundedRectangle(cornerRadius: CornerRadius.regular)
                    .fill(Color.surface))
            }

    }
}

//#Preview {
//    EditListContainer()
//}
