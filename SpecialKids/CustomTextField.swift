//
//  CustomTextField.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isMultiline: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.custom("Outfit-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            } else if isMultiline {
                TextEditor(text: $text)
                    .font(.custom("Outfit-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .font(.custom("Outfit-Regular", size: 16))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                    .padding(.top, 8)
                            }
                        },
                        alignment: .topLeading
                    )
            } else {
                TextField(placeholder, text: $text)
                    .font(.custom("Outfit-Regular", size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .autocapitalization(.none)
    }
}
#Preview {
    LoginView()
}
