//
//  UserAvatar.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

struct UserAvatar: View {
    let username: String
    var size: CGFloat = 60
    
    var body: some View {
        Circle()
            .fill(Color("brandPrimary").opacity(0.2))
            .frame(width: size, height: size)
            .overlay(
                Text(String(username.prefix(1).uppercased()))
                    .font(size > 30 ? .title3.bold() : .caption)
                    .foregroundColor(Color("brandPrimary"))
            )
       
    }
}



#Preview{
    UserAvatar(username: "Manish", size: 30)
}
