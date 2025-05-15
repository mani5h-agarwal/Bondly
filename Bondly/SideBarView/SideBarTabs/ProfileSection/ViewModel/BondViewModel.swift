//
//  BondViewModel.swift
//  Bondly
//
//  Created by Manish Agarwal on 14/05/25.
//

import Foundation
import FirebaseDatabase

@MainActor
class BondViewModel: ObservableObject {
    @Published var isLoading = false
    private var dbRef = Database.database().reference()
    
    func sendBondRequest(from currentUserId: String, to targetUserId: String) async throws {
        guard currentUserId != targetUserId else { return }

        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        let timestamp = Int(Date().timeIntervalSince1970)

        let updates: [String: Any] = [
            "/users/\(currentUserId)/bondRequestsSent/\(targetUserId)": timestamp,
            "/users/\(targetUserId)/bondRequestsReceived/\(currentUserId)": timestamp
        ]

        try await dbRef.updateChildValues(updates)
    }

    func acceptBondRequest(currentUserId: String, from senderId: String) async throws {
        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        // Get current bond counts
        let currentUserSnapshot = try await dbRef.child("users").child(currentUserId).child("bondsCount").getData()
        let senderUserSnapshot = try await dbRef.child("users").child(senderId).child("bondsCount").getData()
        
        var currentUserBondCount = currentUserSnapshot.value as? Int ?? 0
        var senderUserBondCount = senderUserSnapshot.value as? Int ?? 0
        
        // Increment bond counts
        currentUserBondCount += 1
        senderUserBondCount += 1

        let updates: [String: Any] = [
            "/users/\(currentUserId)/bondedUserIds/\(senderId)": true,
            "/users/\(senderId)/bondedUserIds/\(currentUserId)": true,
            "/users/\(currentUserId)/bondRequestsReceived/\(senderId)": NSNull(),
            "/users/\(senderId)/bondRequestsSent/\(currentUserId)": NSNull(),
            "/users/\(currentUserId)/bondsCount": currentUserBondCount,
            "/users/\(senderId)/bondsCount": senderUserBondCount
        ]

        try await dbRef.updateChildValues(updates)
    }

    func rejectBondRequest(currentUserId: String, from senderId: String) async throws {
        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        let updates: [String: Any] = [
            "/users/\(currentUserId)/bondRequestsReceived/\(senderId)": NSNull(),
            "/users/\(senderId)/bondRequestsSent/\(currentUserId)": NSNull()
        ]

        try await dbRef.updateChildValues(updates)
    }

    func cancelBondRequest(from currentUserId: String, to targetUserId: String) async throws {
        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        let updates: [String: Any] = [
            "/users/\(currentUserId)/bondRequestsSent/\(targetUserId)": NSNull(),
            "/users/\(targetUserId)/bondRequestsReceived/\(currentUserId)": NSNull()
        ]

        try await dbRef.updateChildValues(updates)
    }

    func removeBond(between user1Id: String, and user2Id: String) async throws {
        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        // Get current bond counts
        let user1Snapshot = try await dbRef.child("users").child(user1Id).child("bondsCount").getData()
        let user2Snapshot = try await dbRef.child("users").child(user2Id).child("bondsCount").getData()
        
        var user1BondCount = user1Snapshot.value as? Int ?? 0
        var user2BondCount = user2Snapshot.value as? Int ?? 0
        
        // Decrement bond counts, ensuring they don't go below 0
        user1BondCount = max(0, user1BondCount - 1)
        user2BondCount = max(0, user2BondCount - 1)

        let updates: [String: Any] = [
            "/users/\(user1Id)/bondedUserIds/\(user2Id)": NSNull(),
            "/users/\(user2Id)/bondedUserIds/\(user1Id)": NSNull(),
            "/users/\(user1Id)/bondsCount": user1BondCount,
            "/users/\(user2Id)/bondsCount": user2BondCount
        ]

        try await dbRef.updateChildValues(updates)
    }
}
