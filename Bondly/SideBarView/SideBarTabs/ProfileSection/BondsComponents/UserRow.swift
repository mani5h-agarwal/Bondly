//
//  UserRow.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

struct UserRow: View {
    let user: UserPreviewModel
    
    var body: some View {
        HStack(spacing: 12) {
            UserAvatar(username: user.username)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullname)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}
