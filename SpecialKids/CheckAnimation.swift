//
//  CheckAnimation.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 25.11.2024.
//

import SwiftUI

struct SwiftUIView: View {
    @State var isTapped = false
    @State var Animated = false

    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Circle()
                    .frame(width: 10, height: 10)
                    .scaleEffect(Animated ? 1 : 0)
                    .offset(y: Animated ? -50 : 0)
                    .rotationEffect(.degrees(Double(i) * 60))
                    .opacity(Animated ? 1 : 0)
            }
            
            Image(systemName: isTapped ? "checkmark.circle.fill" : "circle")
                .font(.largeTitle)
        }
        .foregroundStyle(isTapped ? .indigo : .white)
        .onAppear {
            startAnimation() // Animasyonları başlat
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(duration: 1)) {
            isTapped.toggle()
        }
        withAnimation(.easeInOut(duration: 0.6)) {
            Animated.toggle()
        }
    }
}

#Preview {
    SwiftUIView()
}
