//
//  UserManager.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import FirebaseFirestore
import Foundation

struct DBUser: Codable {
    let userId: String
    let email: String
    let lists: [String]
    let dateCreated: Date

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email!.lowercased()
        self.lists = []
        self.dateCreated = Date()
    }

    //    enum CodingKeys: String, CodingKey {
    //        case userId: "user_id"
    //        case email: "email"
    //        case lists: "lists"
    //        case dateCreated: "date_created"
    //    }
}

final class UserManager {

    static let shared = UserManager()
    private init() {}

    private let userCollection = Firestore.firestore().collection("users")

    private func userDocument(of userId: String) -> DocumentReference {
        userCollection.document(userId)
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

    func createNewUser(user: DBUser) async throws {
        try userDocument(of: user.userId).setData(
            from: user, merge: false, encoder: encoder)
    }

    func getUser(userId: String) async throws -> DBUser {
        return try await userDocument(of: userId)
            .getDocument(as: DBUser.self, decoder: decoder)
    }

    func createNewList(userId: String, listId: String) async throws {
        let data: [String: Any] = [
            "lists": FieldValue.arrayUnion([listId])
        ]
        do {
            try await userDocument(of: userId).updateData(data)
        } catch {
            throw FirestoreError.updateFailed(
                "Failed to update user document: \(error.localizedDescription)")
        }
    }

    func getLists(userId: String) async throws -> [DBList] {
        let listIds = try await getUser(userId: userId).lists
        var lists: [DBList] = []
        for listId in listIds {
            do {
                let list = try await ListManager.shared.getList(listId: listId)
                lists.append(list)
            } catch {
                print("List with ID \(listId) not found: \(error)")
            }
        }
        return lists
    }

    func deleteList(userId: String, listId: String) async throws {
        let user = try await getUser(userId: userId)
        var userLists = user.lists

        guard let index = userLists.firstIndex(of: listId) else {
            throw NSError(domain: "List not found", code: 404, userInfo: nil)
        }

        userLists.remove(at: index)

        try await userDocument(of: userId).updateData(["lists": userLists])
    }

    func getUserByEmail(email: String) async throws -> DBUser? {
        let querySnapshot = try await userCollection.whereField(
            "email", isEqualTo: email.lowercased()
        ).getDocuments()
        let user = try querySnapshot.documents.first?.data(
            as: DBUser.self,
            decoder: decoder
        )
        return user
    }

    func addSharedList(listId: String, userId: String) async throws {
        try await userDocument(of: userId).updateData([
            "lists": FieldValue.arrayUnion([listId])
        ])
    }

}
