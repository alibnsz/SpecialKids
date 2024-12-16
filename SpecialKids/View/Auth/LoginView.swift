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
            VStack(spacing: 20) {
                Spacer()
                // Lock Icon

                    Image("logo-transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text("Hosgeldiniz")
                    .font(.custom(outfitLight, size: 34))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Giris Yaparak hesabiniza ulasin ve kaldiginiz yerden devam edin.")
                    .font(.custom(outfitThin, size: 14))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                
                    CustomTextField(placeholder: "Email", text: $email)
                    CustomTextField(placeholder: "Password", text: $password)
                
                
                Button("Parolani mi unuttun?") {
                }
                .foregroundColor(Color.gray)
                .font(.custom(outfitMedium, size: 14))
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                CustomButton(title: isLoading ? "Loading..." : "Giris Yap", backgroundColor: Color("BittersweetOrange")) {
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
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 5)
                }
                
                HStack {
                    VStack { Divider().background(Color.gray.opacity(0.5)) }
                    Text("veya")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    VStack { Divider().background(Color.gray.opacity(0.5)) }
                }
                .padding(.vertical, 20)
                
                HStack(spacing: 20) {
                    SocialLoginButton(image: Image("google"))
                    SocialLoginButton(image: Image(systemName: "apple.logo")).foregroundStyle(.black)
                }
                Spacer()
                
                HStack {
                    Text("Henuz bir hesabin yok mu?")
                    
                        .foregroundColor(.gray)
                    NavigationLink(destination: SignUpView()) {
                        Text("Kayit Ol")
                            .foregroundColor(Color("BittersweetOrange"))
                    }
                }
                .font(.custom(outfitMedium, size: 16))
            }
            .padding(24)
            .background(Color(UIColor.white))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct SocialLoginButton: View {
    let image: Image
    
    var body: some View {
        Button(action: {
            // Handle social login
        }) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .frame(width: 90, height: 90)
                .background(Color.white)
                .cornerRadius(15)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

