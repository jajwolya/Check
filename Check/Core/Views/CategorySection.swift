////
////  CategorySection.swift
////  Check
////
////  Created by Jajwol Bajracharya on 12/12/2024.
////
//
//import SwiftUI
//
//struct CategorySection: View {
//    var category: Category
//    @Binding var isAddingItem: Bool
//    var currentCategory: Category
//    @FocusState private var isInputFocused: Bool
//    var saveItem: (Item, Category) -> Void
//    @State private var newItem: Item = Item(
//        name: "", quantity: 1, note: "", isComplete: false)
//
//    var incompleteItems: [Item] {
//        category.items.filter { !$0.isComplete }
//    }
//
//    var completedItems: [Item] {
//        category.items.filter { $0.isComplete }
//    }
//
//    var body: some View {
//        // Incomplete items
//        ForEach(incompleteItems, id: \.self) { item in
//            ItemRow(item: item, isComplete: false)
//        }
//
//        // Completed items
//        ForEach(completedItems, id: \.self) { item in
//            ItemRow(item: item, isComplete: true)
//        }
//
//        // Conditional TextField for adding a new item to this category
//        if isAddingItem && currentCategory == category {
//            addingItemView
//        }
//    }
//
//    private var addingItemView: some View {
//        VStack {
//            TextField(
//                "New Item name",
//                text: $newItem.name,
//                onCommit: { saveItem(newItem, category) }
//            )
//            .focused($isInputFocused)
//            .onAppear { isInputFocused = true }
//
//            HStack {
//                Text("Quantity")
//                Spacer()
//                Button(action: {
//                    withAnimation {
//                        if newItem.quantity > 1 {
//                            newItem.quantity -= 1
//                        }
//                    }
//                }) {
//                    Image(systemName: "minus.circle")
//                }.buttonStyle(.borderless)
//                    .disabled(newItem.quantity == 1)
//
//                Text("\(newItem.quantity)").contentTransition(
//                    .numericText(value: Double(newItem.quantity)))
//
//                Button(action: {
//                    withAnimation {
//                        newItem.quantity += 1
//                    }
//                }) {
//                    Image(systemName: "plus.circle")
//                }.buttonStyle(.borderless)
//            }
//
//            HStack {
//                Text("Note")
//                Spacer()
//                TextField("Note", text: $newItem.note)
//            }
//        }
//    }
//
//}
