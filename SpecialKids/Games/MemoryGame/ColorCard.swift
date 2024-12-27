//
//  ColorCard.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct ColorCard: Identifiable, Equatable {
    let id = UUID()
    var color: Color
    var isFlipped: Bool = false
    var isMatched: Bool = false
    
    static func == (lhs: ColorCard, rhs: ColorCard) -> Bool {
        lhs.id == rhs.id
    }
}
