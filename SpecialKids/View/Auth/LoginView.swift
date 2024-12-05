//
//  LoginView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 22.11.2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State private var isSignUpViewPresented = false
    @State private var isLoading = false // Yükleniyor durumu

    // E-posta doğrulama fonksiyonu
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    var body: some View {
        VStack {
            
            Text("Giriş Yap")
                .foregroundStyle(Color("SoftBlue"))
                .font(.custom(outfitRegular, size: 36))
            
            Text("Devam etmek için lütfen giriş yapın")
                .font(.custom(outfitRegular, size: 16))
                .foregroundStyle(Color("SoftBlue").opacity(0.8))
                .padding(.top, -5)

            CustomTextField(placeholder: "Email", backgroundColor: .white, text: $email)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            
            CustomTextField(placeholder: "Sifre", backgroundColor: .white, text: $password)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            
            // Giriş yap butonunda yükleniyor durumu
            CustomButton(title: isLoading ? "Yükleniyor..." : "Giris Yap", backgroundColor: Color("SoftBlue")) {
                // Boş alan kontrolü
                if email.isEmpty || password.isEmpty {
                    errorMessage = "Lütfen tüm alanları doldurun."
                    return
                }
                
                // E-posta doğrulama
                if !isValidEmail(email) {
                    errorMessage = "Geçersiz e-posta adresi."
                    return
                }
                
                isLoading = true // Yükleniyor başlat
                firebaseManager.signIn(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        // Kullanıcı giriş yaptı, rolüne göre yönlendirme yapılabilir
                        if firebaseManager.currentUserRole == "teacher" {
                            // Öğretmen ekranına yönlendirme
                        } else if firebaseManager.currentUserRole == "parent" {
                            // Veli ekranına yönlendirme
                        }
                    }
                    isLoading = false // Yükleniyor bitti
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .disabled(isLoading) // Yükleniyor durumunda butonu devre dışı bırak

            Button("Kayıt Ol") {
                isSignUpViewPresented = true
            }
            .padding(.top, 5)
            .foregroundColor(.blue)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .padding()
        .sheet(isPresented: $isSignUpViewPresented) {
            SignUpView() // Kayıt olma ekranını burada gösteriyoruz
        }
    }
}
#Preview {
    LoginView()
}
