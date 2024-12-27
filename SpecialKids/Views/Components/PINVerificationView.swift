import SwiftUI

struct PINVerificationView: View {
    @State private var enteredPIN: String = ""
    @State private var randomPIN: String = ""
    @State private var isCorrect: Bool = false
    @State private var showError: Bool = false
    @State private var mathQuestion: (String, Int) = ("", 0)
    @State private var mathAnswer: String = ""
    @State private var showMathVerification: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    colors: [Color("BittersweetOrange").opacity(0.1), Color("FantasyPink").opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Üst başlık alanı
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color("BittersweetOrange"))
                            .padding(.bottom, 10)
                        
                        Text("Ebeveyn Doğrulaması")
                            .font(.custom("Outfit-SemiBold", size: 28))
                            .foregroundColor(.primary)
                        
                        Text("Oyunlar bölümüne erişmek için lütfen doğrulama adımlarını tamamlayın")
                            .font(.custom("Outfit-Regular", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    if !showMathVerification {
                        // PIN doğrulama alanı
                        VStack(spacing: 25) {
                            Text("Ekrandaki PIN Kodunu Girin")
                                .font(.custom("Outfit-Medium", size: 18))
                                .foregroundColor(.secondary)
                            
                            PINDisplayView(pin: randomPIN)
                            
                            CustomSecureField(text: $enteredPIN, placeholder: "PIN Kodunu Girin")
                                .keyboardType(.numberPad)
                                .onChange(of: enteredPIN) { newValue in
                                    if newValue.count > 4 {
                                        enteredPIN = String(newValue.prefix(4))
                                    }
                                }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Matematik sorusu alanı
                        VStack(spacing: 25) {
                            Text("Matematik Sorusunu Cevaplayın")
                                .font(.custom("Outfit-Medium", size: 18))
                                .foregroundColor(.secondary)
                            
                            Text(mathQuestion.0)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                placeholder: "Cevabınızı girin",
                                text: $mathAnswer
                            )
                            .keyboardType(.numberPad)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Doğrulama butonu
                    CustomButtonView(
                        title: showMathVerification ? "Cevapla" : "Doğrula",
                        type: .primary
                    ) {
                        if showMathVerification {
                            verifyMathAnswer()
                        } else {
                            verifyPIN()
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    if showError {
                        Text(showMathVerification ? "Yanlış cevap, tekrar deneyin." : "Yanlış PIN kodu, tekrar deneyin.")
                            .foregroundColor(.red)
                            .font(.custom("Outfit-Regular", size: 14))
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: GameSelectionView(), isActive: $isCorrect) {
                        EmptyView()
                    }
                }
            }
        }
        .onAppear {
            generateRandomPIN()
            generateMathQuestion()
        }
    }
    
    private func generateRandomPIN() {
        randomPIN = String(format: "%04d", Int.random(in: 0...9999))
    }
    
    private func generateMathQuestion() {
        let operations = [
            ("+", { (a: Int, b: Int) -> Int in a + b }),
            ("-", { (a: Int, b: Int) -> Int in a - b }),
            ("×", { (a: Int, b: Int) -> Int in a * b })
        ]
        let operation = operations.randomElement()!
        let num1 = Int.random(in: 5...20)
        let num2 = Int.random(in: 2...10)
        mathQuestion = ("\(num1) \(operation.0) \(num2) = ?", operation.1(num1, num2))
    }
    
    private func verifyPIN() {
        if enteredPIN == randomPIN {
            showMathVerification = true
            showError = false
            enteredPIN = ""
        } else {
            showError = true
            enteredPIN = ""
        }
    }
    
    private func verifyMathAnswer() {
        if Int(mathAnswer) == mathQuestion.1 {
            isCorrect = true
            showError = false
        } else {
            showError = true
            mathAnswer = ""
        }
    }
}

// PIN Gösterim Komponenti
struct PINDisplayView: View {
    let pin: String
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<4) { index in
                Text(String(pin[pin.index(pin.startIndex, offsetBy: index)]))
                    .font(.system(size: 32, weight: .bold))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("BittersweetOrange").opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("BittersweetOrange"), lineWidth: 2)
                    )
            }
        }
    }
}

struct CustomSecureField: View {
    let text: Binding<String>
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String) {
        self.text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            TextField("", text: text)
                .padding()
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .textContentType(.oneTimeCode)
        }
        .padding(.horizontal)
    }
} 
