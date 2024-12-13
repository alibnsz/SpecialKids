//
//  CustomTextField.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI


struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState var isTyping: Bool
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(width: 350, height: 50)
                .focused($isTyping)
                .background(isTyping ? Color("SoftBlue") : Color.primary, in: RoundedRectangle(cornerRadius: 50).stroke(lineWidth: 0.5))
            Text(placeholder)
                .padding(.horizontal, 5)
                .background(.white.opacity(isTyping || !text.isEmpty ? 1 : 0))
                .foregroundStyle(isTyping ? Color("SoftBlue") : Color("OilBlack").opacity(0.5))
                .padding(.leading)
                .offset(y: isTyping || !text.isEmpty ? -27 : 0)

        }
        .animation(.linear(duration: 0.2), value: isTyping)
    }
}
#Preview {
    LoginView()
}
