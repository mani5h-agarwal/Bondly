//
//  Toolbar.swift
//  Bondly
//
//  Created by Manish Agarwal on 15/05/25.
//
import SwiftUI

extension View {
    func withLeadingMenuToolbar(
        title: String,
        showMenu: Binding<Bool>,
        onRefresh: (() -> Void)? = nil,
        trailingIcon: String = "arrow.clockwise"
    ) -> some View {
        self
            .toolbar {
                // Leading Menu + Title
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Button(action: { showMenu.wrappedValue.toggle() }) {
                            Image(systemName: showMenu.wrappedValue ? "xmark" : "line.3.horizontal")
                                .foregroundStyle(Color("brandPrimary"))
                                .contentTransition(.symbolEffect)
                        }
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }

                // Trailing Refresh Button (optional)
                if let onRefresh = onRefresh {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: onRefresh) {
                            Image(systemName: trailingIcon)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color("brandPrimary"))
                        }
                    }
                }
            }
    }
}
