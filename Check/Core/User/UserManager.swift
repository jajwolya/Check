//
//  UserManager.swift
//  Check
//
//  Created by Jajwol Bajracharya on 16/12/2024.
//

import FirebaseFirestore
import Foundation

struct PendingList: Codable {
    let id: String
    let name: String
    let sender: String
}

struct UserList: Equatable, Codable {
    let id: String
    var name: String
}

struct DBUser: Codable {
    let userId: String
    var displayName: String
    let email: String
    var lists: [UserList]
    let pendingLists: [PendingList]
    let dateCreated: Date

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.displayName = auth.email!.lowercased()
        self.email = auth.email!.lowercased()
        self.lists = []
        self.pendingLists = []
        self.dateCreated = Date()
    }
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
    
    func updateDisplayName(userId: String, newDisplayName: String) async throws {
        try await userDocument(of: userId).updateData(["display_name": newDisplayName])
    }

    func updateUserEmail(userId: String, newEmail: String) async throws {
        try await userDocument(of: userId).updateData(["email": newEmail])
    }

    func createNewList(userId: String, newList: UserList) async throws {
        let data: [String: Any] = [
            "id": newList.id,
            "name": newList.name,
        ]
        do {
            try await userDocument(of: userId).updateData([
                "lists": FieldValue.arrayUnion([data])
            ])
        } catch {
            throw FirestoreError.updateFailed(
                "Failed to update user document: \(error.localizedDescription)")
        }
    }

    func getLists(lists: [UserList]) async throws -> [DBList] {
        var dblists: [DBList] = []
        for list in lists {
            do {
                let list = try await ListManager.shared.getList(listId: list.id)
                dblists.append(list)
            } catch {
                print("List with ID \(list.id) not found: \(error)")
            }
        }
        return dblists
    }

    func updateLists(userId: String, updatedLists: [UserList]) async throws {
        print(updatedLists)
        let listData = updatedLists.map { ["id": $0.id, "name": $0.name] }
        try await userDocument(of: userId).updateData(["lists": listData])
    }

    func addUserListener(
        userId: String, completion: @escaping (Result<DBUser, Error>) -> Void
    ) {
        userDocument(of: userId)
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
                    let updatedUser = try document.data(
                        as: DBUser.self, decoder: decoder)
                    // Call the completion handler with the successfully decoded list
                    completion(.success(updatedUser))
                } catch {
                    print(
                        "Error decoding document: \(error.localizedDescription)"
                    )
                    completion(.failure(error))
                }
            }
    }

    func deleteList(userId: String, listId: String) async throws {
        // Fetch the user and their lists
        let user = try await getUser(userId: userId)

        // Ensure your user has lists
        //        guard let lists = user.lists else {
        //            throw NSError(domain: "No lists found for user", code: 404, userInfo: nil)
        //        }

        // Find the index of the list with the specified ID
        guard let index = user.lists.firstIndex(where: { $0.id == listId })
        else {
            throw NSError(domain: "List not found", code: 404, userInfo: nil)
        }

        // Remove the list at the found index
        var updatedLists = user.lists
        updatedLists.remove(at: index)

        // Update the user document with the new array of lists
        let listData = updatedLists.map { ["id": $0.id, "name": $0.name] }  // Adjust if your lists contain different keys
        try await userDocument(of: userId).updateData(["lists": listData])
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

    func addPendingList(
        listId: String, listName: String, sender: String, sendee: DBUser
    ) async throws {
        let userLists = sendee.lists.map { $0.id }
        let sharedLists = sendee.pendingLists.map { $0.id }

        if userLists.contains(listId) {
            print("User already has access to the list.")
            return
        }  // User already has access to list

        if sharedLists.contains(listId) {
            print("List has already been shared with user.")
            return
        }

        let pendingList = PendingList(
            id: listId, name: listName, sender: sender)

        let pendingListData = try encoder.encode(pendingList) as [String: Any]
        try await userDocument(of: sendee.userId).updateData([
            "pending_lists": FieldValue.arrayUnion([pendingListData])
        ])
    }

    func removePendingList(listId: String, userId: String) async throws {
        // Fetch the current user
        let user = try await getUser(userId: userId)

        // Directly use user.pendingLists without optional binding
        var userPendingLists = user.pendingLists

        // Remove the pending list with the specified listId
        userPendingLists.removeAll { pendingList in
            return pendingList.id == listId
        }

        // Update the user's document in Firestore
        try await userDocument(of: userId).updateData([
            "pending_lists": userPendingLists.map {
                [
                    "id": $0.id,
                    "name": $0.name,
                    "sender": $0.sender,
                ]
            }
        ])
    }

    func addSharedList(listId: String, listName: String, userId: String)
        async throws
    {
        let data: [String: Any] = [
            "id": listId,
            "name": listName,
        ]

        do {
            try await userDocument(of: userId).updateData([
                "lists": FieldValue.arrayUnion([data])
            ])
        } catch {
            throw FirestoreError.updateFailed(
                "Failed to update user document: \(error.localizedDescription)")
        }
    }

    func updateListName(userId: String, listId: String, listName: String)
        async throws
    {
        let user = try await getUser(userId: userId)
        guard let index = user.lists.firstIndex(where: { $0.id == listId })
        else {
            throw NSError(domain: "List not found", code: 404, userInfo: nil)
        }

        var updatedLists = user.lists
        updatedLists[index].name = listName

        let listData = updatedLists.map { ["id": $0.id, "name": $0.name] }

        do {
            try await userDocument(of: userId).updateData(["lists": listData])
        } catch {
            throw FirestoreError.updateFailed(
                "Failed to update user document: \(error.localizedDescription)")
        }
    }
}
