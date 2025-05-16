//
//  Date.swift
//  Bondly
//
//  Created by Manish Agarwal on 16/05/25.
//

import SwiftUI
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
