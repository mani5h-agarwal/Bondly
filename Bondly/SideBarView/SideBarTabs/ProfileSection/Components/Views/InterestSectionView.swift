//
//  InterestSectionView.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct InterestSectionView: View {
    let title: String
    let tags: [String]
    @Binding var selectedTags: [String]
    var editable: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "star")
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline)
            }

            ChipsView(tags: tags, editable: editable) { tag, isSelected in
                if let index = tags.firstIndex(of: tag) {
                    ChipView(tag, index: index, isSelected: isSelected)
                }
            } didChangeSelection: { selection in
                if editable {
                    selectedTags = selection
                }
            }
            .padding(.vertical, 10)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
