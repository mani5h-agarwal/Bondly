////
////  UserModel.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////
import Foundation

struct UserModel: Codable, Identifiable {
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
    
    var id: String {
        return uid
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case username
        case fullname
        case email
        case aboutMe
        case bondsCount
        case interests
        case bondedUserIds
        case bondRequestsSent
        case bondRequestsReceived
        case createdAt
    }
}
