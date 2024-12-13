//
//  SignUpView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 22.11.2024.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phone = ""
    @State private var selectedRole: String? = nil
    @State private var errorMessage: String?
    
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    let roles = ["teachers", "parents"]
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.bottom, 10)
            VStack(alignment: .leading, spacing: 8) {
                Text("Kayit Ol")
                    .font(.custom(outfitMedium, size: 34))
                Text("Eğitim dünyamıza katılmak için kaydolun.")
                    .font(.custom(outfitLight, size: 16))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
            
            CustomTextField(placeholder: "Ad Soyad", text: $name)
            CustomTextField(placeholder: "Email", text: $email)
            CustomTextField(placeholder: "Parola", text: $password)
            CustomTextField(placeholder: "Parola Tekrar", text: $confirmPassword)
            CustomTextField(placeholder: "Telefon", text: $phone)
            
            // Role selection with custom styling
            HStack {
                ForEach(roles, id: \.self) { role in
                    Button(action: {
                        selectedRole = role
                    }) {
                        Text(role)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(selectedRole == role ? Color("BittersweetOrange") : Color.gray.opacity(0.1))
                            .foregroundColor(selectedRole == role ? .white : .black)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical)
            
            CustomButton(title: "Kayit Ol", backgroundColor: Color("SoftBlue")) {
                if password != confirmPassword {
                    errorMessage = "Şifreler eşleşmiyor!"
                    return
                }
                
                guard let selectedRole = selectedRole else {
                    errorMessage = "Lütfen bir rol seçin!"
                    return
                }
                
                firebaseManager.signUp(name: name, phone: phone, email: email, password: password, role: selectedRole) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        // Navigate back to login view -  This requires additional navigation setup.
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("Zaten bir hesabin var mi?")
                        .foregroundColor(.gray)
                    Text("Giris Yap")
                        .foregroundColor(Color("SoftBlue"))
                }
            }
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
    }
}

#Preview {
    SignUpView()
}

