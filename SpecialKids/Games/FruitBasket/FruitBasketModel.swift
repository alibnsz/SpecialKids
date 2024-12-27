//
//  FruitBasketModel.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct FruitItem: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let name: String
    let color: Color
    let season: String // Hangi mevsimde yetiştiği
    let vitamin: String // İçerdiği vitaminler
    let funFact: String // Eğlenceli bilgi
    
    static let fruitData = [
        FruitItem(
            emoji: "🍎",
            name: "Elma",
            color: .red,
            season: "Sonbahar",
            vitamin: "C ve B",
            funFact: "Bir elma yemek, kahve içmekten daha fazla enerji verir!"
        ),
        // Diğer meyveler...
    ]
}

struct Basket: Identifiable {
    let id = UUID()
    let targetFruit: String
    var position: CGPoint
    var isCorrect: Bool = false
}
