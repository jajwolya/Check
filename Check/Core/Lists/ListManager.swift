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
    let name: String
    var categories: [DBCategory]
    var users: [String]
    let dateCreated: Date
}

struct DBCategory: Codable {
    var categoryId: String = UUID().uuidString
    var name: String
    var items: [DBItem] = []
}

struct DBItem: Codable {
    var itemId: String = UUID().uuidString
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

    func getList(listId: String) async throws -> DBList {
        return try await listDocument(of: listId)
            .getDocument(as: DBList.self, decoder: decoder)
    }

    func addCategory(to listId: String, category: DBCategory) async throws {
        var list = try await getList(listId: listId)
        list.categories.append(category)
        try listDocument(of: listId)
            .setData(from: list, merge: true, encoder: encoder)
    }

    func addItem(to listId: String, categoryId: String, item: DBItem)
        async throws
    {
        var list = try await getList(listId: listId)
        guard
            let categoryIndex = list.categories.firstIndex(where: {
                $0.categoryId == categoryId
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
            $0.categoryId == categoryId
        }),
            let itemIndex = list.categories[categoryIndex].items.firstIndex(
                where: {
                    $0.itemId == item.itemId
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
        $0.categoryId == categoryId
    }),
        let itemIndex = list.categories[categoryIndex].items.firstIndex(
            where: {
                $0.itemId == item.itemId
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

}
