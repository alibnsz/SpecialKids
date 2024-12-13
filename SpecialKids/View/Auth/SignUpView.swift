    //
//  SignUpView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 22.11.2024.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: String? = nil // Seçilen rol
    @State private var errorMessage: String?

    @ObservedObject var firebaseManager = FirebaseManager.shared

    let roles = ["teachers", "parents"] // Seçilebilecek roller

    var body: some View {
        VStack {
            Text("Kayıt Ol")
                .font(.custom("outfitRegular", size: 36))
                .foregroundStyle(Color("NeutralBlack"))
            Text("Devam etmek için lütfen giriş yapın")
                .font(.custom("outfitRegular", size: 16))
                .foregroundStyle(.gray)
                .padding()
            
            CustomTextField(placeholder: "Email", text: $email)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            CustomTextField(placeholder: "Sifre", text: $password)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            CustomTextField(placeholder: "Sifreyi Tekrarla", text: $confirmPassword)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)

            // Picker kullanımı
            Picker("Rol Seç", selection: $selectedRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role).tag(role as String?)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // Segmented style
            .padding()
            
            CustomButton(title: "Kayit Ol", backgroundColor: Color("NeutralBlack")) {
                if password != confirmPassword {
                    errorMessage = "Şifreler eşleşmiyor!"
                    return
                }

                guard let selectedRole = selectedRole else {
                    errorMessage = "Lütfen bir rol seçin!"
                    return
                }

                firebaseManager.signUp(email: email, password: password, role: selectedRole) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        // Başarıyla kayıt olundu, ekran sıfırlanabilir
                        email = ""
                        password = ""
                        confirmPassword = ""
                        self.selectedRole = nil
                    }
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)


            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
}
