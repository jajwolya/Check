//
//  EditItemSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 2/1/2025.
//

import SwiftUI

struct ItemSheet: View {
    @EnvironmentObject var viewModel: ListViewModel
    @FocusState private var focusedField: Bool
    @State var item: DBItem
    @Binding var currentItem: DBItem?
    let categoryId: String
    let listId: String
    //    var submit: () async throws -> Void

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            VStack(spacing: Padding.regular) {
                TextField("Name", text: $item.name)
                    .padding(Padding.regular)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.regular)
                            .fill(Color.surface)
                    )
                    .focused($focusedField)
                    .onAppear {
                        self.focusedField = true
                    }
                    .submitLabel(.done)

                TextField(
                    "",
                    text: $item.note,
                    prompt: Text("Note").foregroundStyle(Color.surfaceLight)
                )
                .lineLimit(
                    1...5
                )
                .padding(Padding.regular)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.surface)
                )

                HStack(spacing: Padding.regular) {
                    HStack(spacing: Padding.small) {
                        Text("Quantity: ")
                            .foregroundStyle(Color.surfaceLight)
                        Text("\(item.quantity)")
                    }.padding(Padding.regular)
                    Spacer()
                    HStack(spacing: 0) {
                        Button(action: {
                            item.quantity -= 1
                        }) {
                            Image(systemName: "minus")
                                .frame(width: 48, height: 48)
                        }.buttonStyle(.borderless)
                            .opacity(item.quantity == 1 ? 0.5 : 1)
                            .disabled(item.quantity == 1)

                        Divider()
                            .background(Color.surfaceDark)
                            .frame(height: 32)

                        Button(action: { item.quantity += 1 }) {
                            Image(systemName: "plus")
                                .frame(width: 48, height: 48)
                        }.buttonStyle(.borderless)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(
                            Color.surface))
                }
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.regular)
                        .fill(Color.surface)
                )

                Spacer()

                HStack(spacing: Padding.regular) {
                    Button(
                        action: {
                            Task {
                                do {
                                    try await viewModel
                                        .deleteItem(
                                            listId: listId,
                                            categoryId: categoryId, item: item)
                                    currentItem = nil
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }) {
                            Text("Delete")
                                .fontWeight(.medium)
                                .padding(Padding.regular)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: CornerRadius.medium
                                    )
                                    .fill(
                                        Color.surface)
                                )
                        }

                    Button(action: {
                        Task {
                            do {
                                try await viewModel.addItem(
                                    item: item, to: categoryId, in: listId)
                                currentItem = nil
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }) {
                        Text("Save")
                            .fontWeight(.medium)
                            .foregroundStyle(Color.surfaceBackground)
                            .padding(Padding.regular)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: CornerRadius.medium
                                )
                                .fill(Color.light)
                                .opacity(item.name.isEmpty ? 0.5 : 1)
                            )
                    }
                    .disabled(item.name.isEmpty)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .padding(.horizontal, Padding.gutter)
            .padding(.vertical, Padding.medium)
        }
        .presentationDetents([.fraction(0.5), .fraction(0.8)])
        .presentationBackground(.ultraThinMaterial)
    }
}

//#Preview {
//    let item = DBItem(name: "Bread", quantity: 2, note: "Rye", checked: false)
//    EditItemSheet(item: item)
//}
