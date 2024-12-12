import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]

    @State private var newItemName: String = ""
    @State private var newCategoryName: String = ""
    @State private var isAddingCategory: Bool = false
    @State private var isAddingItem: Bool = false
    @State private var currentCategory: Category?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationSplitView {
            List {
                // Categories Section
                Section("Text") {
                    ForEach(categories) { category in
                        Section(header: HStack {
                            Text(category.name)
                            Spacer()
                            Button(action: {
                                currentCategory = category
                                isAddingItem = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }) {
                            categorySectionContent(for: category)
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
                
                // Add Category TextField
                if isAddingCategory {
                    TextField("New Category Name",
                              text: $newCategoryName,
                              onCommit: saveCategory)
                        .focused($isInputFocused)
                        .onAppear { isInputFocused = true }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        newCategoryName = ""
                        isAddingCategory = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Categories")
        } detail: {
            Text("Select a category")
        }
    }
    
    @ViewBuilder
    private func categorySectionContent(for category: Category) -> some View {
        // Incomplete items
        ForEach(category.items.filter { item in !item.isComplete }, id: \.self) { item in ItemRow(item: item, isComplete: false)
        }
        
        // Completed items
        ForEach(category.items.filter { item in item.isComplete }, id: \.self) { item in
            ItemRow(item: item, isComplete: true)
        }
        
        // Conditional TextField for adding new item to this category
        if isAddingItem && currentCategory == category {
            TextField("New Item Name",
                      text: $newItemName,
                      onCommit: { saveItem(in: category) }
            )
            .focused($isInputFocused)
            .onAppear { isInputFocused = true }
        }
    }
    
    private func saveItem(in category: Category) {
        guard !newItemName.trimmingCharacters(in: .whitespaces).isEmpty else {
            isAddingItem = false
            return
        }
        
        withAnimation {
            let newItem = Item(name: newItemName)
            category.items.append(newItem)
            
            do {
                try context.save()
                newItemName = ""
                isAddingItem = false
                isInputFocused = false
            } catch {
                print("Failed to save item: \(error)")
            }
        }
    }
    
    private func saveCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else {
            isAddingCategory = false
            return
        }
        
        withAnimation {
            let newCategory = Category(name: newCategoryName, items: [])
            context.insert(newCategory)
            
            do {
                try context.save()
                newCategoryName = ""
                isAddingCategory = false
                isInputFocused = false
            } catch {
                print("Failed to save category: \(error)")
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(categories[index])
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }
    
    private func toggleItemCompletion(_ item: Item, in category: Category) {
         withAnimation {
             item.isComplete.toggle()
             
             do {
                 try context.save()
             } catch {
                 print("Failed to toggle item completion: \(error)")
             }
         }
     }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Item.self], inMemory: true)
}
