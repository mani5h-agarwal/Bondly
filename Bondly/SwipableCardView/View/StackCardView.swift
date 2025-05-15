//
//  StackCardView.swift
//  Bondly
//
//  Created by Manish Agarwal on 12/05/25.
//

import SwiftUI

struct StackCardView: View {
    @EnvironmentObject var homeData: HomeViewModel
    var user: User
    
    @State var offset: CGFloat = 0
    @GestureState var isDragging: Bool = false
    
    @State var endSwipe: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let index = CGFloat(homeData.getIndex(user: user))
            let topOffset = (index <= 2 ? index : 2) * 20
            
            ZStack {
                let card = RoundedRectangle(cornerRadius: 35)
                    .fill(Color.white)
                    .frame(width: max(size.width - topOffset * 1.5, 0), height: size.height)
                    .offset(y: -topOffset)
                
                if index <= 2 {
                    card
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 1)
                } else {
                    card
                }
                CardContent(user: user)
                    .padding(20)
                    .frame(width: max(size.width - topOffset * 1.5, 0), height: size.height)
                    .offset(y: -topOffset)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .offset(x: offset)
        .rotationEffect(.init(degrees: getRotation(angle: 8)))
        .contentShape(Rectangle().trim(from: 0, to: endSwipe ? 0 : 1))
        .gesture (
            DragGesture()
                .updating($isDragging, body: { value, out, _ in
                    out = true
                })
                .onChanged ({ value in
                    let translation = value.translation.width
                    offset = (isDragging ? translation : .zero)
                })
                .onEnded({ value in
                    let width = getRect().width - 50
                    let translation = value.translation.width
                    let checkingStatus = (translation > 0 ? translation: -translation)
                    withAnimation{
                        if checkingStatus > (width / 2){
                            offset = (translation > 0 ? width : -width) * 2
                            endSwipeActions()
                        }
                        else {
                            offset = .zero
                        }
                    }
                })
        )
    }
    
    func getRotation(angle: Double) -> Double{
        let rotation = (offset / (getRect().width - 50)) * angle
        return rotation
    }
    
    func endSwipeActions(){
        withAnimation(.none){endSwipe = true}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let _ = homeData.displaying_users?.first{
                let _ = withAnimation{
                    homeData.displaying_users?.removeFirst()
                }
            }
        }
    }
}

extension View{
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
}
