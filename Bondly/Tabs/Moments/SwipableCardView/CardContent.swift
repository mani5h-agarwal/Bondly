////
////  CardContent.swift
////  Bondly
////
////  Created by Manish Agarwal on 12/05/25.
////

import SwiftUI

struct CardContent: View {
    var moment: Moment
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var momentViewModel: MomentViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // User Info and Tag
            HStack(alignment: .center, spacing: 16) {
                NavigationLink(destination: LazyProfileView(userId: moment.createrId)){
                    UserAvatar(username: moment.fullname, size: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(moment.fullname)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("@\(moment.username)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(moment.tag)
                    .font(.caption)
                    .foregroundColor(Color("brandPrimary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("brandPrimary").opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer(minLength: 12)
            
            // Description
            Text(moment.content)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 20)
            
            Spacer(minLength: 12)
            
            if let url = URL(string: moment.imageUrl), !moment.imageUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Loading placeholder
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 225)
                            .clipped()
                    case .failure:
                        // Fallback placeholder on error
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                Spacer(minLength: 12)
            }
            
            HStack {
                if let userId = userViewModel.user?.uid {
                    HeartButton(momentVM: momentViewModel, moment: moment, userId: userId)
                } else {
                    
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .opacity(0.5)
                }
                
                Text("\(moment.likes)")
                    .foregroundColor(.gray)
                Spacer()
                
                Text(formatTimestamp(moment.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func formatTimestamp(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct LazyProfileView: View {
    var userId: String
    
    var body: some View {
        ProfileView(userId: userId)
            .id(userId) // Important: This forces SwiftUI to create a new instance for each unique user ID
    }
}
