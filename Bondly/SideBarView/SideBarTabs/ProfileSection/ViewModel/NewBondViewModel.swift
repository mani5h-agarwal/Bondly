////
////  NewBondViewModel.swift
////  Bondly
////
////  Created by Manish Agarwal on 13/05/25.
////
//
//import Foundation
//import FirebaseDatabase
//import FirebaseAuth
//
//@MainActor
//class NewBondViewModel: ObservableObject {
//    @Published var searchText: String = ""
//    @Published var searchResults: [UserPreviewModel] = []
//    @Published var isSearching = false
//
//    func searchUsers() async {
//        guard !searchText.isEmpty else { return }
//        isSearching = true
//        let dbRef = Database.database().reference().child("users")
//        
//        dbRef.observeSingleEvent(of: .value) { [weak self] snapshot in
//            guard let self = self else { return }
//            var matches: [UserPreviewModel] = []
//
//            for child in snapshot.children {
//                if let snap = child as? DataSnapshot,
//                   let dict = snap.value as? [String: Any],
//                   let username = dict["username"] as? String,
//                   username.lowercased().contains(self.searchText.lowercased()) {
//
//                    let uid = snap.key
//                    let user = UserPreviewModel(
//                        uid: uid,
//                        username: username,
//                        fullname: dict["fullname"] as? String ?? username,
//                        aboutMe: dict["aboutMe"] as? String ?? ""
//                    )
//                    matches.append(user)
//                }
//            }
//            self.searchResults = matches
//            self.isSearching = false
//        }
//    }
//}



import Foundation
import FirebaseDatabase
import Combine

@MainActor
class NewBondViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [UserModel] = []
    @Published var isSearching = false
    
    private let dbRef = Database.database().reference()
    
    func searchUsers() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            // Convert search text to lowercase for case-insensitive matching
            let lowercaseSearchText = searchText.lowercased()
            
            let usersRef = dbRef.child("users")
            let snapshot = try await usersRef.getData()
            
            guard let usersDict = snapshot.value as? [String: [String: Any]] else {
                print("❌ Failed to parse users data")
                return
            }
            
            // Process users
            var results: [UserModel] = []
            
            for (uid, userData) in usersDict {
                // First check if username contains search text (case-insensitive)
                if let username = userData["username"] as? String,
                   username.lowercased().contains(lowercaseSearchText) {
                    // Parse the user data
                    if let user = try? decodeUserFromFirebase(userData, uid: uid) {
                        results.append(user)
                    }
                }
            }
            
            // Limit results to avoid overloading the UI
            if results.count > 20 {
                results = Array(results.prefix(20))
            }
            
            // Sort by username relevance (closest match first)
            results.sort { user1, user2 in
                // If one username starts with the search text and the other doesn't, prioritize the one that does
                let starts1 = user1.username.lowercased().starts(with: lowercaseSearchText)
                let starts2 = user2.username.lowercased().starts(with: lowercaseSearchText)
                
                if starts1 != starts2 {
                    return starts1
                }
                
                // Otherwise sort alphabetically
                return user1.username.lowercased() < user2.username.lowercased()
            }
            
            DispatchQueue.main.async {
                self.searchResults = results
            }
            
        } catch {
            print("❌ Error searching users: \(error)")
        }
    }
    
    private func decodeUserFromFirebase(_ data: [String: Any], uid: String) throws -> UserModel {
        guard let username = data["username"] as? String else {
            throw NSError(domain: "NewBondViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing username"])
        }
        guard let email = data["email"] as? String else {
            throw NSError(domain: "NewBondViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing email"])
        }

        let fullname = data["fullname"] as? String ?? username
        let aboutMe = data["aboutMe"] as? String ?? ""
        let bondsCount = data["bondsCount"] as? Int ?? 0
        let interests = data["interests"] as? [String] ?? []
        
        // Ensure we properly handle these complex types
        var bondedUserIds: [String] = []
        if let bondedDict = data["bondedUserIds"] as? [String: Bool] {
            bondedUserIds = Array(bondedDict.keys)
        } else if let bondedArray = data["bondedUserIds"] as? [String] {
            bondedUserIds = bondedArray
        }
        
        let bondRequestsSent = data["bondRequestsSent"] as? [String: Int] ?? [:]
        let bondRequestsReceived = data["bondRequestsReceived"] as? [String: Int] ?? [:]
        let createdAt = data["createdAt"] as? String ?? ""

        return UserModel(
            uid: uid,
            username: username,
            fullname: fullname,
            email: email,
            aboutMe: aboutMe,
            bondsCount: bondsCount,
            interests: interests,
            bondedUserIds: bondedUserIds,
            bondRequestsSent: bondRequestsSent,
            bondRequestsReceived: bondRequestsReceived,
            createdAt: createdAt
        )
    }
}
