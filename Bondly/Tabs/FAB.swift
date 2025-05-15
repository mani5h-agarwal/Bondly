//
//  FAB.swift
//  Bondly
//
//  Created by Manish Agarwal on 13/05/25.
//
import SwiftUI

struct FAB: View {
    @Binding var showFABView: Bool
    let selectedTabBottom: Int

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showFABView = true
                }) {
                    Image(systemName: fabIcon(for: selectedTabBottom))
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 65, height: 65)
                        .background(Color("brandPrimary").gradient)
                        .cornerRadius(18)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }

    private func fabIcon(for tab: Int) -> String {
        switch tab {
        case 0:
            return "person.crop.circle.fill.badge.plus"
        case 1:
            return "photo.badge.plus.fill"
        case 2:
            return "person.2.badge.plus.fill"
        default:
            return "plus"
        }
    }
}
