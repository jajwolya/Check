//
//  ListManager.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import FirebaseFirestore
import Foundation

enum Priority: String, Codable, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
}

struct DBList: Codable {
    let listId: String
    var name: String
    var categories: [DBCategory]
    var users: [String]
    let dateCreated: Date
}

struct DBCategory: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var items: [DBItem] = []
}

struct DBItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var quantity: Int
    var note: String
    //    var priority: Priority
    var checked: Bool

    init(
        name: String,
        quantity: Int,
        note: String,
        //        priority: Priority,
        checked: Bool
    ) {
        self.name = name
        self.quantity = 1
        self.note = ""
        //        self.priority = .normal
        self.checked = false
    }

    init(item: DBItem) {
        self.name = item.name
        self.quantity = item.quantity
        self.note = item.note
        self.checked = item.checked
    }

    static func defaultNewItem() -> DBItem {
        return DBItem(name: "", quantity: 1, note: "", checked: false)
    }
}

final class ListManager {
    static let shared = ListManager()
    private init() {}
    
    private let listCollection = Firestore.firestore().collection("lists")
    
    private func listDocument(of listId: String) -> DocumentReference {
        listCollection.document(listId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    @discardableResult
    func createNewList(name: String, userId: String) async throws -> String {
        let newListRef = listCollection.document()
        let newList = DBList(
            listId: newListRef.documentID,
            name: name,
            categories: [],
            users: [userId],
            dateCreated: Date()
        )
        try newListRef.setData(from: newList, merge: false, encoder: encoder)
        return newListRef.documentID
    }
    
    //    func getLists(listIds: [String]) async throws -> [DBList] {
    //        let query = listCollection.whereField(FieldPath.documentID(), in: listIds)
    //
    //    }
    
    func getList(listId: String) async throws -> DBList {
        do {
            return try await listDocument(of: listId)
                .getDocument(as: DBList.self, decoder: decoder)
        } catch {
            throw CustomError.failedToFetchList(
                listId: listId,
                underlyingError: error
            )
        }
    }
    
    func addListenerForLists(
        listId: String, completion: @escaping (Result<DBList, Error>) -> Void
    ) {
        listDocument(of: listId)
            .addSnapshotListener { [self] documentSnapshot, error in
                if let error = error {
                    print(
                        "Error fetching document: \(error.localizedDescription)"
                    )
                    completion(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    completion(
                        .failure(
                            NSError(
                                domain: "DocumentError", code: 404,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Document does not exist."
                                ])))
                    return
                }
                
                do {
                    // Decode the document into your DBList model
                    let updatedList = try document.data(
                        as: DBList.self, decoder: decoder)
                    // Call the completion handler with the successfully decoded list
                    completion(.success(updatedList))
                } catch {
                    print(
                        "Error decoding document: \(error.localizedDescription)"
                    )
                    completion(.failure(error))
                }
            }
    }
    
    func addCategory(to listId: String, category: DBCategory) async throws {
        var list = try await getList(listId: listId)
        list.categories.append(category)
        try listDocument(of: listId)
            .setData(from: list, merge: true, encoder: encoder)
    }
    
    func deleteCategory(listId: String, categoryId: String) async throws {
        var list = try await getList(listId: listId)
        if let categoryIndex = list.categories.firstIndex(where: {
            $0.id == categoryId
        }) {
            list.categories.remove(at: categoryIndex)
            try listDocument(of: listId).setData(
                from: list, merge: true, encoder: encoder)
        } else {
            throw NSError(
                domain: "Category not found", code: 404, userInfo: nil)
        }
    }
    
    func addItem(to listId: String, categoryId: String, item: DBItem)
    async throws
    {
        var list = try await getList(listId: listId)
        guard
            let categoryIndex = list.categories.firstIndex(where: {
                $0.id == categoryId
            })
        else {
            throw NSError(domain: "Category not found", code: 404)
        }
        list.categories[categoryIndex].items.append(item)
        try listDocument(of: listId).setData(
            from: list, merge: true, encoder: encoder)
    }
    
    func toggleCheckedItem(listId: String, categoryId: String, item: DBItem)
    async throws
    {
        var list = try await getList(listId: listId)
        if let categoryIndex = list.categories.firstIndex(where: {
            $0.id == categoryId
        }),
           let itemIndex = list.categories[categoryIndex].items.firstIndex(
            where: {
                $0.id == item.id
            })
        {
            list.categories[categoryIndex].items[itemIndex].checked.toggle()
            try listDocument(of: listId).setData(
                from: list, merge: true, encoder: encoder)
        } else {
            throw NSError(
                domain: "Item or category not found", code: 404, userInfo: nil)
        }
    }
    
    func deleteItem(listId: String, categoryId: String, item: DBItem)
    async throws
    {
        var list = try await getList(listId: listId)
        if let categoryIndex = list.categories.firstIndex(where: {
            $0.id == categoryId
        }),
           let itemIndex = list.categories[categoryIndex].items.firstIndex(
            where: {
                $0.id == item.id
            })
        {
            list.categories[categoryIndex].items.remove(at: itemIndex)
            try listDocument(of: listId).setData(
                from: list, merge: true, encoder: encoder)
        } else {
            throw NSError(
                domain: "Item or category not found", code: 404, userInfo: nil)
        }
    }
    
    func deleteList(listId: String, userId: String) async throws {
        var list = try await getList(listId: listId)
        if let index = list.users.firstIndex(of: userId) {
            list.users.remove(at: index)
        }
        if list.users.isEmpty {
            try await listDocument(of: listId).delete()
        } else {
            try listDocument(of: listId)
                .setData(from: list, merge: true, encoder: encoder)
        }
    }
    
    func addUser(listId: String, userId: String) async throws {
        try await listDocument(of: listId).updateData([
            "users": FieldValue.arrayUnion([userId])
        ])
    }
    
    func updateCategoryItems(listId: String, categoryId: String, with updatedItems: [DBItem]) async throws {
        // Fetch the current list from the database
        var list = try await getList(listId: listId)
        
        // Find the index of the specified category
        if let categoryIndex = list.categories.firstIndex(where: { $0.id == categoryId }) {
            // Update the items in the found category
            list.categories[categoryIndex].items = updatedItems
            
            // Persist the updated list back to the database
            try listDocument(of: listId)
                .setData(from: list, merge: true, encoder: encoder)
        } else {
            throw NSError(domain: "Category not found", code: 404, userInfo: nil)
        }
    }
    
    func updateCategories(listId: String, updatedCategories: [DBCategory]) async throws {
        var list = try await getList(listId: listId)
        list.categories = updatedCategories
        try listDocument(of: listId).setData(from: list, merge: true, encoder: encoder)
    }
    
    func updateListName(listId: String, listName: String) async throws {
        let listData: [String: Any] = ["name": listName]
        try await listDocument(of: listId).updateData(listData)
    }

    
}
