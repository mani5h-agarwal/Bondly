//
//  User.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct User: Identifiable {
    var id = UUID().uuidString
    var name: String
    var place: String
    var profilePic: String
    var likes: Int
}
