//
//  HeaderView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct HeaderView: View {
    // Profil fotoğrafı ve ikonları için değişkenler
    let profileImage: Image
    let onUsersButtonTapped: () -> Void
    let onNotificationsButtonTapped: () -> Void

    var body: some View {
        HStack {
            // Profil resmi
            profileImage
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.leading)

            Spacer()

            // Kullanıcı ikonları
            HStack(spacing: 20) {
                // Kullanıcı butonu
                Button(action: {
                    onUsersButtonTapped() // Kullanıcılar butonuna basılınca çağrılan fonksiyon
                }) {
                    Image(systemName: "person.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding()
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Çerçeve
                        .foregroundStyle(Color(.black))
                }

                // Bildirim butonu
                Button(action: {
                    onNotificationsButtonTapped() // Bildirimler butonuna basılınca çağrılan fonksiyon
                }) {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding()
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Çerçeve
                        .foregroundStyle(Color(.black))

                }
            }
            .padding(.trailing)
        }
        .frame(height: 60)
    }
}
