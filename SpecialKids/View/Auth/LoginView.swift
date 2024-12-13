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
    @State private var isLoading = false

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hosgeldiniz")
                        .font(.custom(outfitMedium, size: 36))
                    Text("Giriş yaparak hesabınıza ulaşın ve kaldığınız yerden devam edin.")
                        .font(.custom(outfitLight, size: 16))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)
                
                CustomTextField(placeholder: "Email", text: $email)
                CustomTextField(placeholder: "Password", text: $password)
                
                HStack {
                    Spacer()
                    Button("Forget password?") {
                        // Handle forgot password
                    }
                    .foregroundColor(Color("SoftBlue"))
                    .font(.custom(outfitLight, size: 16))
                }
                
                CustomButton(title: isLoading ? "Yükleniyor..." : "Giris Yap", backgroundColor: Color("SoftBlue")) {
                    if email.isEmpty || password.isEmpty {
                        errorMessage = "Lütfen tüm alanları doldurun."
                        return
                    }
                    
                    if !isValidEmail(email) {
                        errorMessage = "Geçersiz e-posta adresi."
                        return
                    }
                    
                    isLoading = true
                    firebaseManager.signIn(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            if firebaseManager.currentUserRole == "teacher" {
                                // Öğretmen ekranına yönlendirme
                            } else if firebaseManager.currentUserRole == "parent" {
                                // Veli ekranına yönlendirme
                            }
                        }
                        isLoading = false
                    }
                }
                .disabled(isLoading)
                
                Text("veya")
                    .font(.custom(outfitLight, size: 16))
                    .foregroundColor(.gray)
                    .padding(.vertical)
                
                CustomButton(title: "Apple ile devam et", backgroundColor: Color("OilBlack")) {}
                CustomButton(title: "Google ile devam et", backgroundColor: Color("BittersweetOrange")) {}

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Spacer()
                
                NavigationLink(destination: SignUpView()) {
                    HStack {
                        Text("Henuz bir hesabin yok mu?")
                            .foregroundColor(.gray)
                        Text("Kayit Ol")
                            .foregroundColor(Color("SoftBlue"))
                    }
                    .font(.custom(outfitLight, size: 18))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        }
    }
}

#Preview {
    LoginView()
}

