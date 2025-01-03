//
//  FruitBasketViewModel.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore

class FruitBasketViewModel: ObservableObject {
    @Published private(set) var targetFruit: FruitItem
    @Published private(set) var options: [FruitItem] = []
    @Published private(set) var score: Int = 0
    @Published var message = "Aynı meyveyi bul! 🎯"
    @Published var showConfetti = false
    @Published var scoreChange = false
    @Published var gameCompleted = false
    @Published var correctAnswer = false
    @Published var correctMatches = 0
    @Published var wrongMatches = 0
    @Published var fruitResults: [FruitMatchResult] = []
    
    private var unusedFruits: [(String, String, Color, String, String, String)]
    private var audioPlayer: AVAudioPlayer?
    private var startTime: Date?
    private var playTime: TimeInterval = 0
    private var isGameActive = false
    private var hasGameBeenSaved = false
    
    let fruitData = [
        ("🍎", "Elma", Color.red, "Sonbahar", "C ve B", "Bir elma yemek, kahve içmekten daha fazla enerji verir!"),
        ("🍌", "Muz", Color.yellow, "Yaz", "B6 ve C", "Muzlar aslında bir ot türüdür, ağaç değil!"),
        ("🍊", "Portakal", Color.orange, "Kış", "C", "Portakalın kabuğu D vitamini içerir!"),
        ("🍇", "Üzüm", Color.purple, "Sonbahar", "C ve K", "Üzümler ay ışığında daha tatlı olur!"),
        ("🍓", "Çilek", Color.pink, "İlkbahar", "C", "Çilek aslında bir meyve değil, çiçeğin şişmiş sapıdır!"),
        ("🍐", "Armut", Color.green, "Sonbahar", "C ve K", "Armutlar suda yüzebilir!"),
        ("🍑", "Şeftali", Color(.systemPink), "Yaz", "A ve C", "Şeftali ağaçları 20-30 yıl yaşayabilir!"),
        ("🍍", "Ananas", Color.yellow, "Yaz", "C ve B", "Bir ananas olgunlaşmak için 2-3 yıl bekler!")
    ]
    
    init() {
        targetFruit = FruitItem(
            emoji: "🍎",
            name: "Elma",
            color: .red,
            season: "Sonbahar",
            vitamin: "C ve B",
            funFact: "Bir elma yemek, kahve içmekten daha fazla enerji verir!"
        )
        unusedFruits = fruitData
        startNewRound()
    }
    
    func startNewRound() {
        if unusedFruits.isEmpty {
            gameCompleted = true
            message = "Tebrikler! Tüm meyveleri buldun! 🎉"
            return
        }
        
        let availableFruits = unusedFruits.shuffled()
        targetFruit = FruitItem(
            emoji: availableFruits[0].0,
            name: availableFruits[0].1,
            color: availableFruits[0].2,
            season: availableFruits[0].3,
            vitamin: availableFruits[0].4,
            funFact: availableFruits[0].5
        )
        
        // Doğru cevabı unusedFruits'ten kaldır
        unusedFruits.removeAll { $0.0 == targetFruit.emoji }
        
        // Seçenekleri oluştur
        var optionFruits = [targetFruit]
        let wrongOptions = fruitData.filter { $0.0 != targetFruit.emoji }.shuffled().prefix(2)
        optionFruits.append(contentsOf: wrongOptions.map { fruit in
            FruitItem(
                emoji: fruit.0,
                name: fruit.1,
                color: fruit.2,
                season: fruit.3,
                vitamin: fruit.4,
                funFact: fruit.5
            )
        })
        
        options = optionFruits.shuffled()
        message = "\(targetFruit.name)'yı bul! 🎯"
        showConfetti = false
    }
    
    func checkFruit(_ selectedFruit: FruitItem) {
        if let start = startTime {
            playTime += Date().timeIntervalSince(start)
            startTime = Date()
        }
        
        if selectedFruit == targetFruit {
            // Doğru seçim
            correctMatches += 1
            withAnimation {
                score += 10
                scoreChange = true
                message = "Harika! Doğru meyveyi buldun! 🎉"
                correctAnswer.toggle()
            }
            
            // Doğru eşleşmeyi kaydet
            fruitResults.append(FruitMatchResult(
                fruitName: selectedFruit.name,
                isCorrect: true,
                attemptCount: 1
            ))
            
            playSound("correct")
            
            // Score animasyonunu resetle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scoreChange = false
            }
            
            // Yeni round başlamadan önce süreyi durdur
            endGame()
            
            // Eğer tüm meyveler tamamlandıysa oyunu kaydet
            if unusedFruits.isEmpty && !hasGameBeenSaved {
                print("Saving game results...") // Debug için
                saveGameResults()
                hasGameBeenSaved = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.startGame()
                    self.startNewRound()
                }
            }
        } else {
            // Yanlış seçim
            wrongMatches += 1
            withAnimation {
                score = max(0, score - 5)
                scoreChange = true
                message = "Tekrar dene! Bu \(selectedFruit.name) değil 💪"
                correctAnswer = false
            }
            
            // Yanlış eşleşmeyi kaydet
            if let index = fruitResults.firstIndex(where: { $0.fruitName == selectedFruit.name }) {
                fruitResults[index].attemptCount += 1
            } else {
                fruitResults.append(FruitMatchResult(
                    fruitName: selectedFruit.name,
                    isCorrect: false,
                    attemptCount: 1
                ))
            }
            
            playSound("wrong")
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func playSound(_ name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Ses çalınamadı!")
        }
    }
    
    func startGame() {
        startTime = Date()
        isGameActive = true
    }
    
    func endGame() {
        guard isGameActive, let start = startTime else { return }
        playTime += Date().timeIntervalSince(start)
        startTime = nil
        isGameActive = false
    }
    
    func saveGameResults() {
        guard !hasGameBeenSaved else { 
            print("Game already saved, skipping...")
            return 
        }
        
        FirebaseManager.shared.fetchFirstChild { [weak self] student in
            guard let self = self, let student = student else { 
                print("No student found")
                return 
            }
            
            // Son süre güncellemesi
            if let start = startTime {
                playTime += Date().timeIntervalSince(start)
            }
            
            print("Preparing game data for save...") // Debug için
            
            let gameData: [String: Any] = [
                "studentId": student.id,
                "correctMatches": self.correctMatches,
                "wrongMatches": self.wrongMatches,
                "score": self.score,
                "fruits": self.fruitResults.map { fruit in
                    [
                        "fruitName": fruit.fruitName,
                        "isCorrect": fruit.isCorrect,
                        "attemptCount": fruit.attemptCount
                    ]
                },
                "playTime": self.playTime,
                "dailyPlayTime": self.playTime,
                "gameCompleted": true,
                "lastPlayDate": Timestamp(date: Date()),
                "lastStreakDate": Timestamp(date: Date()),
                "streak": 1
            ]
            
            print("Saving to Firestore...") // Debug için
            
            Firestore.firestore().collection("gameStats").addDocument(data: gameData) { [weak self] error in
                if let error = error {
                    print("Error saving game stats: \(error.localizedDescription)")
                } else {
                    print("Game stats saved successfully")
                    
                    // Günlük hedef süreyi güncelle
                    FirebaseManager.shared.updateDailyPlayTime(for: student.id, additionalTime: self?.playTime ?? 0)
                    
                    // Bildirim gönder
                    NotificationCenter.default.post(name: NSNotification.Name("GameCompleted"), object: nil)
                }
            }
        }
    }
}
