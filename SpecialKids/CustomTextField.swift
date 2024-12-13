//
//  CustomTextField.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI


import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    @FocusState var focused: Bool
    var body: some View {
        let isActive = focused || text.count > 0
        
        ZStack(alignment: isActive ? .topLeading : .center) {
            TextField("", text: $text)
                .frame(height: 24)
                .font(.system(size: 16, weight: .regular))
                .opacity(isActive ? 1 : 0)
                .offset(y: 7)
                .focused($focused)
            
            HStack {
                Text(placeholder)
                    .foregroundColor(.black.opacity(0.3))
                    .frame(height: 16)
                    .font(.system(size: isActive ? 12 : 16, weight: .regular))
                    .offset(y: isActive ? -7 : 0)
                Spacer()
            }
        }
        .onTapGesture {
            focused = true
        }
        .animation(.linear(duration: 0.1), value: focused)
        .frame(height: 50)
        .padding(.horizontal, 16)
        .background(.white)
        .cornerRadius(50)
        .overlay {
            RoundedRectangle(cornerRadius: 50)
                .stroke(focused ? .black.opacity(0.6) : .black.opacity(0.2), lineWidth: 1)
        }
    }
}
#Preview {
    LoginView()
}
