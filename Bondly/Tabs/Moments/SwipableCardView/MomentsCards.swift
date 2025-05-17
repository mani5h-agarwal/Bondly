//
//  MomentsCards.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct MomentsCards: View {
    @EnvironmentObject var momentData: MomentViewModel

    var body: some View {
        VStack {
            ZStack {
                if momentData.isLoading && momentData.displaying_moments.isEmpty {
                    ProgressView()
                } else if momentData.displaying_moments.isEmpty {
                    EmptyStateView(
                        title: "No Moments Found",
                        message: "Looks like there are no new moments right now. Try checking back later!",
                        systemImage: "clock.arrow.circlepath"
                    )
                } else {
                    ForEach(momentData.displaying_moments.reversed()) { moment in
                        StackCardView(moment: moment)
                    }
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
