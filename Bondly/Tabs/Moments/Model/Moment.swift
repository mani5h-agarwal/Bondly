//
//  Moment.swift
//  Bondly
//
//  Created by Manish Agarwal on 17/05/25.
//

import Foundation

struct Moment: Identifiable, Codable {
    var id: String { momentId }
    let momentId: String
    let createrId: String
    let username: String
    let fullname: String
    let timestamp: Double
    let content: String
    let tag: String
    let imageUrl: String
    var likes: Int
    var isLikedByCurrentUser: Bool = false
}
