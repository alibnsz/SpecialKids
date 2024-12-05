//
//  CustomTextField.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String // Placeholder metni
    var backgroundColor: Color // Arka plan rengi
    @Binding var text: String // TextField'in bağlandığı metin değişkeni

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.custom(outfitLight, size: 18))
            .padding() // İç boşluk
            .frame(maxWidth: .infinity) // Genişliği tam ekran yapar
            .background(backgroundColor) // Arka plan rengi
            .cornerRadius(10) // Köşe yuvarlama
            .shadow(radius: 1) // Gölgeleme
            .foregroundColor(.black) // Yazı rengi siyah
            .textFieldStyle(PlainTextFieldStyle()) // Basit metin alanı stili
            .accentColor(.black)
    }
}
