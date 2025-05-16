////
////  BondButton.swift
////  Bondly
////
////  Created by Manish Agarwal on 13/05/25.
////
//import SwiftUI
//
//struct BondButton: View {
//    let currentUser: UserModel
//    let targetUser: UserModel
//    let onSendBondRequest: () async -> Void
//    let onCancelBondRequest: () async -> Void
//    let onAcceptBondRequest: () async -> Void
//    let onRejectBondRequest: () async -> Void
//    let onRemoveBond: () async -> Void
//
//    @State private var isPerformingAction = false
//
//    var body: some View {
//        VStack {
//            if currentUser.bondedUserIds.contains(targetUser.id) {
//                bondActionButton(label: "Remove", icon: "minus.circle.fill", color: .gray.opacity(0.2), action: onRemoveBond, isPerformingAction)
//            } else if currentUser.bondRequestsSent.keys.contains(targetUser.id) {
//                bondActionButton(label: "Cancel", icon: "xmark.circle", color: .gray.opacity(0.2), action: onCancelBondRequest, isPerformingAction)
//            } else if currentUser.bondRequestsReceived.keys.contains(targetUser.id) {
//                HStack(spacing: 12) {
//                    bondActionButton(label: "Accept", icon: "checkmark.circle.fill", color: Color("brandPrimary"), action: onAcceptBondRequest, isPerformingAction)
//                    bondActionButton(label: "Decline", icon: "xmark.circle.fill", color: .gray.opacity(0.2), action: onRejectBondRequest, isPerformingAction)
//                }
//                
//            } else {
//                bondActionButton(label: "Bond", icon: "link.badge.plus", color: Color("brandPrimary"), action: onSendBondRequest, isPerformingAction)
//            }
//        }
//    }
//
//    private func bondActionButton(label: String, icon: String, color: Color, action: @escaping () async -> Void, _ isPerformingAction: Bool) -> some View {
//        Button {
//            performAction(action)
//        } label: {
//            HStack {
//                if isPerformingAction {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .foregroundStyle(Color.white)
//                } else {
//                    Image(systemName: icon)
//                    Text(label)
//                }
//            }
//            .font(.headline)
//            .fontWeight(.bold)
//            .frame(width: 135, height: 45)
//            .background(color)
//            .foregroundColor((label == "Remove" || label == "Accept") ? .white : .gray)
//            .cornerRadius(.infinity)
//        }
//        .disabled(isPerformingAction)
//    }
//
//    private func performAction(_ action: @escaping () async -> Void) {
//        Task {
//            isPerformingAction = true
//            await action()
//            isPerformingAction = false
//        }
//    }
//}


import SwiftUI

struct BondButton: View {
    let currentUser: UserModel
    let targetUser: UserModel
    let onSendBondRequest: () async -> Void
    let onCancelBondRequest: () async -> Void
    let onAcceptBondRequest: () async -> Void
    let onRejectBondRequest: () async -> Void
    let onRemoveBond: () async -> Void

    @State private var isPerformingAction = false

    var body: some View {
        VStack {
            if currentUser.bondedUserIds.contains(targetUser.id) {
                // Already bonded
                actionButton(
                    label: "Remove",
                    icon: "link.circle.fill",
                    isPrimary: false,
                    action: onRemoveBond
                )
                .contextMenu {
                    Button(role: .destructive) {
                        performAction(onRemoveBond)
                    } label: {
                        Label("Remove", systemImage: "link.badge.minus")
                    }
                }
            } else if currentUser.bondRequestsSent.keys.contains(targetUser.id) {
                // Pending sent request
                actionButton(
                    label: "Requested",
                    icon: "clock.fill",
                    isPrimary: false,
                    action: onCancelBondRequest
                )
            } else if currentUser.bondRequestsReceived.keys.contains(targetUser.id) {
                // Pending received request
                HStack(spacing: 10) {
                    actionButton(
                        label: "Accept",
                        icon: "checkmark.circle.fill",
                        isPrimary: true,
                        action: onAcceptBondRequest
                    )
                    
                    actionButton(
                        label: "Decline",
                        icon: "xmark.circle.fill",
                        isPrimary: false,
                        action: onRejectBondRequest
                    )
                }
            } else {
                // Not bonded
                actionButton(
                    label: "Bond",
                    icon: "link.badge.plus",
                    isPrimary: true,
                    action: onSendBondRequest
                )
            }
        }
    }

    private func actionButton(
        label: String,
        icon: String,
        isPrimary: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            performAction(action)
        } label: {
            HStack(spacing: 8) {
                if isPerformingAction {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isPrimary ? .white : Color("brandPrimary")))
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                    
                }
            }
            .frame(width: 110)
            .frame(height: 40)
            .padding(.horizontal, 16)
            .background(
                isPrimary ?
                    Color("brandPrimary") :
                    Color("brandPrimary").opacity(0.1)
            )
            .foregroundColor(isPrimary ? .white : Color("brandPrimary"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isPrimary ? Color.clear : Color("brandPrimary"),
                        lineWidth: 1
                    )
            )
        }
        .disabled(isPerformingAction)
    }

    private func performAction(_ action: @escaping () async -> Void) {
        Task {
            isPerformingAction = true
            await action()
            isPerformingAction = false
        }
    }
}
