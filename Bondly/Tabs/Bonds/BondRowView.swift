//
//  BondRowView.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI

struct BondRowView: View {
    let userId: String
    let onTap: () -> Void
    
    @State private var userPreview: UserPreviewModel?
    @State private var isLoading = true
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if isLoading {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                } else if let preview = userPreview {
                    UserAvatar(username: preview.username)
                } else {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if isLoading {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 18)
                            .frame(width: 150)
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                            .frame(width: 100)
                    } else if let preview = userPreview {
                        Text(preview.fullname)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("@\(preview.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Unknown User")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("User not available")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Timestamp or unread message indicator could go here
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            await loadUserPreview()
        }
    }
    
    private func loadUserPreview() async {
        isLoading = true
        defer { isLoading = false }
        
        userPreview = await userViewModel.fetchUserPreview(userId: userId)
    }
}

