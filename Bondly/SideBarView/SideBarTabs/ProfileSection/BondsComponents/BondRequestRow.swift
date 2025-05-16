//
//  BondRequestRow.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI


enum BondRequestType {
    case received
    case sent
}

struct BondRequestRow: View {
    let userId: String
    let timestamp: Int
    let type: BondRequestType
    
    @State private var user: UserPreviewModel?
    @State private var isLoading = true
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            if isLoading {
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .frame(width: 120)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .frame(width: 80)
                    }
                    
                    Spacer()
                }
                .redacted(reason: .placeholder)
            } else if let user = user {
                HStack(spacing: 12) {
                    NavigationLink(destination: ProfileView(userId: user.uid)) {
                        HStack(spacing: 12) {
                            UserAvatar(username: user.username)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(formatTimestamp(timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                }
            } else {
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unknown User")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("User not available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
        }
//        .padding(.horizontal)
        .task {
            await loadUser()
        }
    }
    
    private func loadUser() async {
        isLoading = true
        defer { isLoading = false }
        
        // Use the shared user view model to fetch just a preview
        user = await userViewModel.fetchUserPreview(userId: userId)
    }
    
    private func formatTimestamp(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
