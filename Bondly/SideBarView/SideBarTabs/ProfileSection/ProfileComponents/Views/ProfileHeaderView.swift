//
//  ProfileHeaderView.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//
import SwiftUI

struct ProfileHeaderView: View {
    let profileImage: String
    let fullName: String
    let userName: String
    let bondsCount: Int
    @Binding var editedFullName: String
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack {
//            Image(systemName: profileImage)
//                .resizable()
//                .foregroundColor(.gray.opacity(0.6))
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 100, height: 100)
//                .clipShape(Circle())
//                .overlay(
//                    Circle().stroke(Color.purple.opacity(0.5), lineWidth: 6)
//                )
//                .overlay(
//                    Circle().stroke(Color.white, lineWidth: 3).padding(2)
//                )
//            
            Circle()
                .fill(Color("brandPrimary").opacity(0.3))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(String(userName.prefix(1).uppercased()))
                        .font(.title)
                        .foregroundColor(Color("brandPrimary"))
                )
                .overlay(
                    Circle().stroke(Color.purple.opacity(0.5), lineWidth: 6)
                )
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 3).padding(2)
                )

            VStack(spacing: 4) {
                if isEditing {
                    TextField("Full Name", text: $editedFullName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    Text(fullName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Text("@\(userName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("\(bondsCount)").fontWeight(.regular)
                    Text("Bonds").foregroundStyle(.gray)
                }
                .padding(.top, 6)
            }
            .padding(.top, 10)
        }
    }
}

