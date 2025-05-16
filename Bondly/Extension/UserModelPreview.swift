//
//  UserModelPreview.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//
import SwiftUI
extension UserPreviewModel {
    static func fromFirebaseData(_ data: [String: Any], uid: String) throws -> UserPreviewModel {
        guard let username = data["username"] as? String else {
            throw NSError(domain: "UserPreviewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing username"])
        }
        
        let fullname = data["fullname"] as? String ?? username

        return UserPreviewModel(
            uid: uid,
            username: username,
            fullname: fullname
        )
    }
}
