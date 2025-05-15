//
//  HomeViewModel.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var fetched_users: [User] = []
    @Published var displaying_users: [User]?
    
    init() {
        fetched_users = [
            User (name: "Natalia", place: "Vadalia NY", profilePic: "User1", likes: 20),
            User (name: "Elisa", place: "Central Park NYC", profilePic: "User2", likes: 20),
            User (name: "Jasmine", place: "Metropolitan Museum NYC", profilePic: "User3", likes: 20),
            User (name: "Zahra", place: "Liberty NYC", profilePic: "User4", likes: 20),
            User (name: "Angelina", place: "Empier State NYC", profilePic: "User5", likes: 20),
            User (name: "Brittany", place: "Time Square NYC", profilePic: "User6", likes: 20),
        ]
        
        displaying_users = fetched_users
    }
    
    func getIndex(user: User)->Int{
        let index = displaying_users?.firstIndex (where: { currentUser in
            return user.id == currentUser.id
        }) ?? 0
        return index
    }
}
