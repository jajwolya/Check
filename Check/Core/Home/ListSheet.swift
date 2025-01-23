//
//  ListSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 8/1/2025.
//

import SwiftUI

struct ListSheet: View {
//    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var viewModel: HomeViewModel
    @FocusState private var focusedField: Bool
    @State var list: DBList
    //    var listId: String?
    var isEditing: Bool = false
    var dismissAction: () -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.medium) {
                
                Text(isEditing ? "Rename list" : "Create list")
                    .font(.title3).fontWeight(.semibold).foregroundStyle(Color.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
                TextField("\(list.name)", text: $list.name, prompt: Text("List name"))
                    .padding(Padding.regular)
                    .disableAutocorrection(true)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.regular)
                            .fill(Color.surface)
                    )
                    .submitLabel(.done)

                Spacer()

                HStack(spacing: Padding.regular) {
                    if isEditing {
                        Button(
                            action: {
                                Task {
                                    do {
                                        try await viewModel
                                            .deleteList(
                                                id: list.listId)
                                        dismissAction()
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }) {
                                Text("Delete")
                                    .fontWeight(.medium)
                                    .padding(Padding.regular)
                                    .frame(
                                        maxWidth: .infinity, alignment: .center
                                    )
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: CornerRadius.medium
                                        )
                                        .fill(
                                            Color.surface)
                                    )
                            }
                    } else {
                        Button(
                            action: {
                                dismissAction()
                            }) {
                                Text("Cancel")
                                    .fontWeight(.medium)
                                    .padding(Padding.regular)
                                    .frame(
                                        maxWidth: .infinity, alignment: .center
                                    )
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: CornerRadius.medium
                                        )
                                        .fill(
                                            Color.surface)
                                    )
                            }
                    }

                    Button(
                        action: {
                            if isEditing {
                                Task {
                                    do {
                                        try await viewModel
                                            .updateListName(
                                                list: list
                                            )
                                        dismissAction()
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            } else {
                                Task {
                                    do {
                                        try await viewModel.addNewList(
                                            listName: list.name)
                                        dismissAction()
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }

                        }) {
                            Text(isEditing ? "Save" : "Add")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.surfaceBackground)
                                .padding(Padding.regular)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(Color.light)
                                    .opacity(list.name.isEmpty ? 0.5 : 1)
                                )
                        }
                        .disabled(list.name.isEmpty)
                }
            }
//            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(Color.content)
            .padding(.horizontal, Padding.gutter)
            .padding(.top, Padding.large)
            .padding(.bottom, Padding.medium)
        }
        .presentationDetents([.fraction(1)])
        .presentationBackground(.ultraThinMaterial)
    }
}

//#Preview {
//    let item = DBItem(name: "Bread", quantity: 2, note: "Rye", checked: false)
//    EditItemSheet(item: item)
//}
