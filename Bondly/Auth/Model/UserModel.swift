////
////  UserModel.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////
import Foundation


// Base protocol for user models with common properties
protocol UserModelProtocol: Identifiable {
    var uid: String { get }
    var username: String { get }
    var fullname: String { get }
}

// Lightweight model for list displays and basic information
struct UserPreviewModel: UserModelProtocol, Codable {
    let uid: String
    let username: String
    let fullname: String
    
    var id: String { uid }
    
    // Initialize from full user model
    init(from user: UserModel) {
        self.uid = user.uid
        self.username = user.username
        self.fullname = user.fullname
    }
    
    // Initialize directly
    init(uid: String, username: String, fullname: String) {
        self.uid = uid
        self.username = username
        self.fullname = fullname
    }
}

// Complete user model for profile and detailed views
struct UserModel: UserModelProtocol, Codable {
    let uid: String
    let username: String
    var fullname: String
    let email: String
    var aboutMe: String
    var bondsCount: Int
    var interests: [String]
    var bondedUserIds: [String]
    var bondRequestsSent: [String: Int]    // [userId: timestamp]
    var bondRequestsReceived: [String: Int] // [userId: timestamp]
    let createdAt: String
    
    var id: String { uid }
    
    // Create a preview from this full model
    var preview: UserPreviewModel {
        return UserPreviewModel(from: self)
    }
}
