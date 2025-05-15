//
//  AuthManager.swift
//  Bondly
//
//  Created by Manish Agarwal on 07/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct AuthManager {

    static func signup(username: String, email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid

        let userData: [String: Any] = [
            "uid": uid,
            "username": username,
            "email": email,
            "aboutMe": "Hey there, I am using Bondly",
            "bondsCount": 0,
            "interests": [],
            "bondedUserIds": [],
            "createdAt": Date().description
        ]

        let ref = Database.database().reference()
        try await ref.child("users").child(uid).setValue(userData)

        return try await authResult.user.getIDToken()
    }

    static func login(email: String, password: String) async throws -> String {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let token = try await authResult.user.getIDToken()
        return token
    }

    static func logout() throws {
        try Auth.auth().signOut()
    }
}
