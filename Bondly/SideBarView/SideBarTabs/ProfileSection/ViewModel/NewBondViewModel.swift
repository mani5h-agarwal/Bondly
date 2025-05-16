//////
//////  NewBondViewModel.swift
//////  Bondly
//////
//////  Created by Manish Agarwal on 13/05/25.

import Foundation
import FirebaseDatabase
import Combine

@MainActor
class NewBondViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [UserPreviewModel] = []
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
            
            // Process users - only extract needed fields for preview
            var results: [UserPreviewModel] = []
            
            for (uid, userData) in usersDict {
                // First check if username contains search text (case-insensitive)
                if let username = userData["username"] as? String,
                   username.lowercased().contains(lowercaseSearchText) {
                    // Only parse the fields we need for display
                    if let userPreview = try? UserPreviewModel.fromFirebaseData(userData, uid: uid) {
                        results.append(userPreview)
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
    
    // Method to fetch full user details when needed
    func fetchFullUserDetails(for userId: String) async -> UserModel? {
        do {
            let userRef = dbRef.child("users").child(userId)
            let snapshot = try await userRef.getData()
            
            guard let userData = snapshot.value as? [String: Any] else {
                print("❌ Failed to fetch full user data")
                return nil
            }
            
            return try UserModel.fromFirebaseData(userData, uid: userId)
        } catch {
            print("❌ Error fetching full user details: \(error)")
            return nil
        }
    }
}
