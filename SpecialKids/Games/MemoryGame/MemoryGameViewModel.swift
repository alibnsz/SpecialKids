//
//  MemoryGameViewModel.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI
import AVFoundation

class MemoryGameViewModel: ObservableObject {
    @Published private(set) var cards: [MemoryCard] = []
    @Published private(set) var score: Int = 0
    @Published var showCelebration: Bool = false
    @Published var currentMessage = "Kartları eşleştir!"
    
    private var firstFlippedCardIndex: Int? = nil
    private var audioPlayer: AVAudioPlayer?
    
    let cardData = [
        ("🐶", "Köpek", "woof", Color.pink),
        ("🐱", "Kedi", "meow", Color.orange),
        ("🐮", "İnek", "moo", Color.green),
        ("🐔", "Tavuk", "cluck", Color.yellow),
        ("🐷", "Domuz", "oink", Color.purple),
        ("🐸", "Kurbağa", "ribbit", Color.blue)
    ]
    
    init() {
        resetGame()
    }
    
    func resetGame() {
        let shuffledData = (cardData + cardData).shuffled()
        cards = shuffledData.map { emoji, name, sound, color in
            MemoryCard(emoji: emoji, color: color, name: name, sound: sound)
        }
        score = 0
        showCelebration = false
        currentMessage = "Kartları eşleştir!"
        firstFlippedCardIndex = nil
    }
    
    func playSound(_ name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ses çalınamadı!")
        }
    }
    
    func cardTapped(_ tappedIndex: Int) {
        if cards[tappedIndex].isMatched || cards[tappedIndex].isFaceUp { return }
        
        cards[tappedIndex].isFaceUp = true
        
        if let firstIndex = firstFlippedCardIndex {
            // İkinci kart çevrildiğinde
            if cards[firstIndex].emoji == cards[tappedIndex].emoji {
                // Eşleşme varsa
                cards[firstIndex].isMatched = true
                cards[tappedIndex].isMatched = true
                score += 10
                playSound("success")
                currentMessage = "Harika! \(cards[tappedIndex].name)leri eşleştirdin! 🎉"
                
                if cards.allSatisfy({ $0.isMatched }) {
                    showCelebration = true
                    playSound("win")
                }
            } else {
                // Eşleşme yoksa
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.cards[firstIndex].isFaceUp = false
                    self.cards[tappedIndex].isFaceUp = false
                    self.currentMessage = "Tekrar dene! 💪"
                }
                playSound("wrong")
            }
            firstFlippedCardIndex = nil
        } else {
            // İlk kart çevrildiğinde
            firstFlippedCardIndex = tappedIndex
            playSound(cards[tappedIndex].sound)
            currentMessage = "Şimdi eşini bul!"
        }
    }
}
