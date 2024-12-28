import SwiftUI

struct GameStats: Codable {
    var correctMatches: Int
    var wrongMatches: Int
    var score: Int
    var lastPlayedDate: Date
    var fruits: [FruitMatchResult]
    var playTime: TimeInterval
    var dailyPlayTime: TimeInterval
    var gameCompleted: Bool
    var streak: Int
    var lastStreakDate: Date
    var studentId: String
}

struct FruitMatchResult: Codable {
    var fruitName: String
    var isCorrect: Bool
    var attemptCount: Int
} 
