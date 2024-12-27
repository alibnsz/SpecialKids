//
//  MemoryCardView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct MemoryCardView: View {
    let card: MemoryCard
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 20)
            
            if card.isFaceUp || card.isMatched {
                shape
                    .fill(card.color.opacity(0.3))
                    .overlay(
                        shape
                            .stroke(card.color, lineWidth: 2)
                    )
                
                VStack {
                    Text(card.emoji)
                        .font(.system(size: 40))
                    Text(card.name)
                        .font(.caption.bold())
                        .foregroundColor(card.color)
                }
            } else {
                shape
                    .fill(
                        LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing)
                    )
                    .overlay(
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(height: 100)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
