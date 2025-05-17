//
//  UserModel.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

extension UserModel {
    static func fromFirebaseData(_ data: [String: Any], uid: String) throws -> UserModel {
        guard let username = data["username"] as? String else {
            throw NSError(domain: "UserModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing username"])
        }
        guard let email = data["email"] as? String else {
            throw NSError(domain: "UserModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing email"])
        }

        let fullname = data["fullname"] as? String ?? username
        let aboutMe = data["aboutMe"] as? String ?? ""
        let bondsCount = data["bondsCount"] as? Int ?? 0
        let interests = data["interests"] as? [String] ?? []
        
        // Handle complex types
        var bondedUserIds: [String] = []
        if let bondedDict = data["bondedUserIds"] as? [String: Bool] {
            bondedUserIds = Array(bondedDict.keys)
        } else if let bondedArray = data["bondedUserIds"] as? [String] {
            bondedUserIds = bondedArray
        }
        
        let bondRequestsSent = data["bondRequestsSent"] as? [String: Int] ?? [:]
        let bondRequestsReceived = data["bondRequestsReceived"] as? [String: Int] ?? [:]
        let createdAt = data["createdAt"] as? String ?? ""
        let moments = data["moments"] as? [String] ?? []
        
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
            createdAt: createdAt,
            moments: moments
        )
    }
}
