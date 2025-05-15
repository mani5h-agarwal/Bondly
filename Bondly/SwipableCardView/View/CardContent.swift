//
//  CardContent.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct CardContent: View {
    var user: User

    var body: some View {
        VStack(alignment: .leading) {
   
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color("brandPrimary").opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(user.name.prefix(1).uppercased()))
                            .font(.title2)
                            .foregroundColor(Color("brandPrimary"))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(user.place)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            Spacer()
            // Description
            Text("Some long description. In this video, I'm going to show how to re-create a complex Tinder-like UI with gesture-enabled swipeable cards using SwiftUI.ke UI with gesture-enabled swipeable cards using SwiftUI.  ")
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
            Spacer()
            // Placeholder Image
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 210)
                .overlay(
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                )
                .cornerRadius(12)
            Spacer()
            // Action Row
            HStack {
                HeartButton()
                Text("\(user.likes)")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}
