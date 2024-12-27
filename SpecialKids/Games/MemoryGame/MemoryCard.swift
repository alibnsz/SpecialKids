//
//  MemoryCard.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let color: Color
    let name: String
    let sound: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}
