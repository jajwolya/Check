//import SwiftData
//import SwiftUI
//
//struct ContentView: View {
//    @Environment(\.modelContext) private var context
//    @Query private var categories: [Category]
//    @State private var newCategoryName: String = ""
//    @State private var isAddingCategory: Bool = false
//    @State private var isAddingItem: Bool = false
//    @State private var currentCategory: Category?
//    @FocusState private var isInputFocused: Bool
//    var settingsView: () -> SettingsView
//
//    var body: some View {
//        NavigationStack {
//            List {
//                categoryLists
//                if isAddingCategory {
//                    categoryTextField
//                }
//            }
//            .toolbar { toolbarContent }
//            .navigationTitle("Categories")
//        }
//    }
//
//    // MARK: - View Components
//
//    private var categoryLists: some View {
//        ForEach(categories) { category in
//            Section(header: categoryHeader(for: category)) {
//                CategorySection(
//                    category: category,
//                    isAddingItem: $isAddingItem,
//                    currentCategory: category,
//                    saveItem: { item, category in
//                        saveItem(item: item, in: category)
//                    }
//                )
//            }
//        }
//        .onDelete(perform: deleteCategories)
//    }
//
//    private func categoryHeader(for category: Category) -> some View {
//        HStack {
//            Text(category.name)
//            Spacer()
//            Button(action: {
//                currentCategory = category
//                isAddingItem = true
//            }) {
//                Image(systemName: "plus")
//            }
//        }
//    }
//
//    private var categoryTextField: some View {
//        TextField(
//            "New Category Name", text: $newCategoryName, onCommit: saveCategory
//        )
//        .focused($isInputFocused)
//        .onAppear { isInputFocused = true }
//    }
//
//    private var toolbarContent: some ToolbarContent {
//        Group {
//            ToolbarItem(placement: .topBarLeading) {
//                NavigationLink(destination: settingsView()) {
//                    Image(systemName: "ellipsis")
//                }
//            }
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: {
//                    newCategoryName = ""
//                    isAddingCategory = true
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//    }
//
//    // MARK: - Data Handling Functions
//
//    private func saveItem(item: DBItem, in category: Category) {
//        guard !item.name.trimmingCharacters(in: .whitespaces).isEmpty else {
//            isAddingItem = false
//            return
//        }
//        withAnimation {
//            let newItem = DBItem(
//                name: item.name, quantity: item.quantity, note: item.note,
//                isComplete: false)
//            category.items.append(newItem)
//            for existingItem in category.items {
//                print(
//                    "Item Name: \(existingItem.name), Quantity: \(existingItem.quantity), Note: \(existingItem.note), Is Complete: \(existingItem.isComplete)"
//                )
//            }
//            do {
//                try context.save()
//                isAddingItem = false
//                isInputFocused = false
//            } catch {
//                print("Failed to save item: \(error)")
//            }
//        }
//    }
//
//    private func saveCategory() {
//        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty
//        else {
//            isAddingCategory = false
//            return
//        }
//
//        withAnimation {
//            let newCategory = Category(name: newCategoryName, items: [])
//            context.insert(newCategory)
//
//            do {
//                try context.save()
//                newCategoryName = ""
//                isAddingCategory = false
//                isInputFocused = false
//            } catch {
//                print("Failed to save category: \(error)")
//            }
//        }
//    }
//
//    private func deleteCategories(at offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                context.delete(categories[index])
//            }
//
//            do {
//                try context.save()
//            } catch {
//                print("Failed to delete category: \(error)")
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView {
//        SettingsView(showSignInView: .constant(false))
//    }
//    .modelContainer(for: [Category.self, Item.self], inMemory: true)
//}
