//
//  AboutSectionView.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI
struct AboutSectionView: View {
    let aboutMe: String
    @Binding var editedAboutMe: String
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                Text("About")
                    .font(.headline)
                Spacer()
            }

            if isEditing {
                ExpandingTextEditor(text: $editedAboutMe)
                    .padding(.top, 4)
            } else {
                Text(aboutMe.isEmpty ? "No information provided" : aboutMe)
                    .font(.body)
                    .foregroundColor(aboutMe.isEmpty ? .gray : .secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
            }
        }
    }
}
