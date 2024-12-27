//
//  FruitBasketView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct FruitBasketView: View {
    @StateObject private var viewModel = FruitBasketViewModel()
    @State private var scale = 1.0
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            // Daha canlı gradient arka plan
            LinearGradient(
                colors: [
                    viewModel.targetFruit.color.opacity(0.6),
                    .blue.opacity(0.3),
                    viewModel.targetFruit.color.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.targetFruit)
            
            // Arka plan partikülleri için yeni view kullan
            BackgroundParticles(color: viewModel.targetFruit.color, viewModel: viewModel)
            
            VStack(spacing: 20) {
                // Üst bilgi paneli
                HStack {
                    ScoreView(score: viewModel.score, scoreChange: viewModel.scoreChange)
                    
                    Spacer()
                    
                    RestartButton(action: viewModel.startNewRound)
                }
                .padding()
                
                Spacer()
                
                if viewModel.gameCompleted {
                    GameCompletedView(score: viewModel.score)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    GameContentView(
                        targetFruit: viewModel.targetFruit,
                        message: viewModel.message,
                        options: viewModel.options,
                        checkFruit: viewModel.checkFruit,
                        scale: scale
                    )
                }
                
                Spacer()
            }
        }
        .onAppear {
            isRotating = true
        }
    }
}

// Yardımcı View'lar
struct ScoreView: View {
    let score: Int
    let scoreChange: Bool
    
    var body: some View {
        Text("Puan: \(score)")
            .font(.title2.bold())
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 5)
            )
            .scaleEffect(scoreChange ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scoreChange)
    }
}

struct RestartButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(Color.green.opacity(0.8))
                        .shadow(radius: 5)
                )
        }
    }
}

struct GameContentView: View {
    let targetFruit: FruitItem
    let message: String
    let options: [FruitItem]
    let checkFruit: (FruitItem) -> Void
    let scale: CGFloat
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Hedef meyve
            VStack {
                Text("Bu meyveyi bul:")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Text(targetFruit.emoji)
                    .font(.system(size: 120))
                    .shadow(radius: 10)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: rotation
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            rotation = 5
                        }
                    }
            }
            .padding()
            
            // Mesaj
            Text(message)
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(radius: 5)
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.5), value: message)
            
            // Seçenekler
            HStack(spacing: 15) {
                ForEach(options) { fruit in
                    FruitOptionButton(fruit: fruit, action: { checkFruit(fruit) })
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FruitOptionButton: View {
    let fruit: FruitItem
    let action: () -> Void
    @State private var isPressed = false
    @State private var bounce = 1.0
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack {
                Text(fruit.emoji)
                    .font(.system(size: 60))
                Text(fruit.name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [
                                fruit.color.opacity(0.7),
                                fruit.color.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: isPressed ? 2 : 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(.white.opacity(0.5), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : bounce)
            .onChange(of: isPressed) { oldValue, newValue in
                if !newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        bounce = 1.0
                    }
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                bounce = 1.03
            }
        }
    }
}

struct GameCompletedView: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Tebrikler! 🎉")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("Tüm meyveleri buldun!")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Toplam Puan: \(score)")
                .font(.title.bold())
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange.opacity(0.8))
                        .shadow(radius: 5)
                )
        }
        .padding()
    }
}

struct BackgroundParticles: View {
    let color: Color
    let viewModel: FruitBasketViewModel
    @State private var positions: [(CGPoint, CGFloat)] = []
    @State private var isAnimating = false
    @State private var lastAnimationTime = Date()
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { index in
                if index < positions.count {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: positions[index].1, height: positions[index].1)
                        .position(
                            isAnimating ?
                            CGPoint(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            ) : positions[index].0
                        )
                        .animation(
                            .spring(response: Double.random(in: 0.5...1.5), dampingFraction: 0.7),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            positions = (0..<20).map { _ in
                (
                    CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    CGFloat.random(in: 10...30)
                )
            }
        }
        .onChange(of: viewModel.correctAnswer) { oldValue, newValue in
            let now = Date()
            if now.timeIntervalSince(lastAnimationTime) >= 1.0 {
                withAnimation(.spring()) {
                    isAnimating.toggle()
                }
                lastAnimationTime = now
            }
        }
    }
}
