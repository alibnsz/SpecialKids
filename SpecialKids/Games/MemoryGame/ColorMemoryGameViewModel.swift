//
//  ColorMemoryGameViewModel.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

class ColorMemoryGameViewModel: ObservableObject {
    @Published private(set) var cards: [ColorCard] = []
    @Published private(set) var score: Int = 0
    @Published var showCelebration: Bool = false
    
    private var firstFlippedCard: ColorCard?
    
    let colors: [Color] = [
        Color(hex: "FF6B6B"), // Yumuşak kırmızı
        Color(hex: "4ECDC4"), // Turkuaz
        Color(hex: "45B7D1"), // Mavi
        Color(hex: "96CEB4"), // Yeşil
        Color(hex: "FFEEAD"), // Sarı
        Color(hex: "D4A5A5"), // Pembe
        Color(hex: "9B5DE5"), // Mor
        Color(hex: "FF9A8B")  // Somon
    ]
    
    init() {
        resetGame()
    }
    
    func resetGame() {
        let gameColors = (colors.shuffled().prefix(4) + colors.shuffled().prefix(4)).shuffled()
        cards = gameColors.map { ColorCard(color: $0) }
        score = 0
        showCelebration = false
    }
    
    func cardTapped(_ card: ColorCard) {
        guard let index = cards.firstIndex(of: card),
              !cards[index].isFlipped,
              !cards[index].isMatched else { return }
        
        cards[index].isFlipped = true
        
        if let firstCard = firstFlippedCard {
            checkMatch(firstCard: firstCard, secondCard: cards[index])
        } else {
            firstFlippedCard = cards[index]
        }
    }
    
    private func checkMatch(firstCard: ColorCard, secondCard: ColorCard) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard let firstIndex = self.cards.firstIndex(of: firstCard),
                  let secondIndex = self.cards.firstIndex(of: secondCard) else { return }
            
            if firstCard.color == secondCard.color {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.cards[firstIndex].isMatched = true
                    self.cards[secondIndex].isMatched = true
                    self.score += 10
                    
                    if self.cards.allSatisfy({ $0.isMatched }) {
                        self.showCelebration = true
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.cards[firstIndex].isFlipped = false
                    self.cards[secondIndex].isFlipped = false
                }
            }
            
            self.firstFlippedCard = nil
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
