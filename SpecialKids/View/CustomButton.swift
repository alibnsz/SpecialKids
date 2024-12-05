//
//  MyButton.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct CustomButton: View {
    var title: String // Buton başlığı
    var backgroundColor: Color // Arka plan rengi
    var action: () -> Void // Buton tıklandığında yapılacak işlem

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom(outfitLight, size: 20))
                .foregroundColor(.white) // Başlık rengi beyaz
                .padding() // İç boşluk
                .frame(maxWidth: .infinity) // Butonun genişliğini tam ekran yapar
                .background(backgroundColor) // Arka plan rengi
                .cornerRadius(15) // Köşe yuvarlama
                .shadow(radius: 5) // Gölgeleme
        }
        .buttonStyle(PlainButtonStyle()) // Standart buton stili
    }
}
#Preview {
    TeacherView()
}
