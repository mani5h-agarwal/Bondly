//
//  MomentsCards.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct MomentsCards: View {
    @StateObject var homeData: HomeViewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                if let users = homeData.displaying_users {
                    if users.isEmpty {
                        Text("Come back later we can find more matches for you!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    else {
                        ForEach(users.reversed()) { user in
                            StackCardView(user: user)
                                .environmentObject(homeData)
                        }
                    }
                }
                else {
                    ProgressView()
                }
            }
            .padding(.vertical, 40)
            .padding(20)
            .padding(.bottom, 20)
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// Placeholder for the Add Moment view
struct AddMomentView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add your new moment here")
                    .padding()
                
                // Add your form fields, image picker, etc. here
                
                Spacer()
            }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Add your post logic here
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    MomentsCards()
}
