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
    @State private var showPassword = false
    
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image("logo-transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 32)
                
                Text("Hosgeldiniz")
                    .font(.custom("Outfit-ExtraBold", size: 34))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Giris Yaparak hesabiniza ulasin ve kaldiginiz yerden devam edin.")
                    .font(.custom("Outfit-Light", size: 14))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                
                CustomTextField(placeholder: "Email", text: $email)
                ZStack(alignment: .trailing) {
                    CustomTextField(
                        placeholder: "Şifre",
                        text: $password,
                        isSecure: !showPassword
                    )
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
                
                Button("Parolani mi unuttun?") {
                }
                .foregroundColor(Color.gray)
                .font(.custom("Outfit-Medium", size: 14))
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                
                CustomButtonView(
                    title: "Giriş Yap",
                    isLoading: isLoading,
                    
                    disabled: email.isEmpty || password.isEmpty || !isValidEmail(email),
                    type: .primary
                ) {
                    signIn()
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.custom("Outfit-Regular", size: 14))
                        .padding(.top, 5)
                }
                
                HStack {
                    VStack { Divider().background(Color.gray.opacity(0.5)) }
                    Text("veya")
                        .font(.custom("Outfit-Regular", size: 14))
                        .foregroundColor(.gray)
                    VStack { Divider().background(Color.gray.opacity(0.5)) }
                }
                .padding(.vertical, 20)
                
                HStack(spacing: 20) {
                    SocialLoginButton(image: Image("google"))
                    SocialLoginButton(image: Image(systemName: "apple.logo"))
                        .foregroundStyle(.black)
                }
                Spacer()
                
                HStack {
                    Text("Henuz bir hesabin yok mu?")
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: SignUpView()
                        .navigationBarBackButtonHidden(true)
                    ) {
                        Text("Kayit Ol")
                            .font(.custom("Outfit-Medium", size: 16))
                            .foregroundColor(Color("BittersweetOrange"))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .background(Color(UIColor.white))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func signIn() {
        isLoading = true
        firebaseManager.signIn(email: email, password: password) { error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    if firebaseManager.currentUserRole == "teacher" {
                        withAnimation {
                            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                            let window = scene?.windows.first
                            window?.rootViewController = UIHostingController(
                                rootView: TeacherTabView()
                                    .environmentObject(firebaseManager)
                            )
                        }
                    }
                }
                isLoading = false
            }
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
