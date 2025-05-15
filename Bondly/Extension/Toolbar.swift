//
//  Toolbar.swift
//  Bondly
//
//  Created by Manish Agarwal on 15/05/25.
//

import SwiftUI

extension View {
    func withLeadingMenuToolbar(title: String, showMenu: Binding<Bool>) -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Button(action: { showMenu.wrappedValue.toggle() }) {
                            Image(systemName: showMenu.wrappedValue ? "xmark" : "line.3.horizontal")
                                .foregroundStyle(Color.primary)
                                .contentTransition(.symbolEffect)
                        }
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
            }
    }
}
