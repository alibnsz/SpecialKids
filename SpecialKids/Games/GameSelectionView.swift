//
//  GameSelectionView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct GameSelectionView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    colors: [.blue.opacity(0.7), .purple.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Hareketli arka plan partikülleri
                MovingParticles()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Başlık
                        Text("Eğitici Oyunlar")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.top, 30)
                        
                        // Oyun kartları
                        GameCard(
                            title: "Meyve Sepeti",
                            description: "Meyveleri eşleştir ve öğren!",
                            emoji: "🍎",
                            color: .red,
                            destination: AnyView(FruitBasketView())
                        )
                        
                        GameCard(
                            title: "Hafıza Oyunu",
                            description: "Kartları eşleştirerek hafızanı test et!",
                            emoji: "🎴",
                            color: .blue,
                            destination: AnyView(MemoryGameView())
                        )
                        
                        // Diğer oyunlar buraya eklenebilir...
                    }
                    .padding()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar(.hidden, for: .tabBar) // TabBar'ı gizle
    }
}

struct GameCard: View {
    let title: String
    let description: String
    let emoji: String
    let color: Color
    let destination: AnyView
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 20) {
                // Emoji kısmı
                Text(emoji)
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(color.opacity(0.3))
                    )
                
                // Metin kısmı
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Ok işareti
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.7),
                                color.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: isPressed ? 2 : 5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            // Basma efekti için
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

struct MovingParticles: View {
    @State private var positions: [(CGPoint, CGFloat, Color)] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { index in
                if index < positions.count {
                    Circle()
                        .fill(positions[index].2.opacity(0.3))
                        .frame(width: positions[index].1, height: positions[index].1)
                        .position(positions[index].0)
                        .animation(
                            Animation.linear(duration: Double.random(in: 3...6))
                                .repeatForever(),
                            value: positions[index].0
                        )
                }
            }
        }
        .onAppear {
            // Rastgele renkler
            let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
            
            // Başlangıç pozisyonları
            positions = (0..<30).map { _ in
                (
                    CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    CGFloat.random(in: 10...30),
                    colors.randomElement() ?? .blue
                )
            }
            
            // Sürekli hareket
            withAnimation(.linear(duration: 5).repeatForever()) {
                positions = positions.map { pos in
                    (
                        CGPoint(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        ),
                        pos.1,
                        pos.2
                    )
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
