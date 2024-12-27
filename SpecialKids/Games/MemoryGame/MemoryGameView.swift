//
//  MemoryGameView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 27.12.2024.
//

import SwiftUI

struct MemoryGameView: View {
    @StateObject private var viewModel = MemoryGameViewModel()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            // Renkli arka plan
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                Text("🎯 Hayvan Hafıza Oyunu 🎯")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .blue],
                                     startPoint: .leading,
                                     endPoint: .trailing)
                    )
                    .padding()
                
                Text("Puan: \(viewModel.score)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.purple)
                
                Text(viewModel.currentMessage)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
                    .padding()
                    .animation(.spring, value: viewModel.currentMessage)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                        MemoryCardView(card: card)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    viewModel.cardTapped(index)
                                }
                            }
                    }
                }
                .padding()
                
                Button(action: {
                    withAnimation {
                        viewModel.resetGame()
                    }
                }) {
                    Text("🔄 Yeni Oyun")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(colors: [.purple, .blue],
                                                  startPoint: .leading,
                                                  endPoint: .trailing)
                                )
                        )
                        .shadow(radius: 5)
                }
            }
        }
        .alert("🎉 Tebrikler! 🎉", isPresented: $viewModel.showCelebration) {
            Button("Yeni Oyun", action: viewModel.resetGame)
        } message: {
            Text("Süpersin! Tüm hayvanları eşleştirdin!\nPuanın: \(viewModel.score)")
        }
    }
}
