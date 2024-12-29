import SwiftUI

struct PINVerificationView: View {
    @Binding var pin: String
    @Binding var isVerified: Bool
    @State private var enteredPIN: String = ""
    @State private var randomPIN: String = ""
    @State private var showError: Bool = false
    @State private var navigateToGames = false
    
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
                
                VStack(spacing: 20) {
                    // Üst başlık alanı
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color("BittersweetOrange"))
                            .padding(.bottom, 8)
                        
                        Text("Ebeveyn Doğrulaması")
                            .font(.custom("Outfit-SemiBold", size: 24))
                            .foregroundColor(.primary)
                        
                        Text("Oyunlar bölümüne erişmek için lütfen doğrulama adımlarını tamamlayın")
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 24)
                    
                    // PIN doğrulama alanı
                    VStack(spacing: 24) {
                        Text("Ekrandaki PIN Kodunu Girin")
                            .font(.custom("Outfit-Medium", size: 18))
                            .foregroundColor(.secondary)
                        
                        PINDisplayView(pin: randomPIN)
                            .padding(.vertical, 12)
                        
                        CustomTextField(
                            placeholder: "PIN Kodunu Girin",
                            text: $enteredPIN,
                            isSecure: true
                        )
                        .keyboardType(.numberPad)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    
                    // Doğrulama butonu
                    CustomButtonView(
                        title: "Doğrula",
                        type: .primary
                    ) {
                        verifyPIN()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    
                    if showError {
                        Text("Yanlış PIN kodu, tekrar deneyin.")
                            .foregroundColor(.red)
                            .font(.custom("Outfit-Regular", size: 16))
                            .padding(.top, 12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(isPresented: $navigateToGames) {
                GameSelectionView()
            }
            .onAppear {
                generateRandomPIN()
            }
        }
    }
    
    private func generateRandomPIN() {
        randomPIN = String(format: "%04d", Int.random(in: 0...9999))
    }
    
    private func verifyPIN() {
        if enteredPIN == randomPIN {
            isVerified = true
            showError = false
            navigateToGames = true
        } else {
            showError = true
            enteredPIN = ""
        }
    }
}

// PIN Gösterim Komponenti
struct PINDisplayView: View {
    let pin: String
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<4) { index in
                let pinDigits = Array(pin)
                Text(index < pinDigits.count ? String(pinDigits[index]) : "")
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

// PIN Field Komponenti
struct PINField: View {
    @Binding var pin: String
    
    var body: some View {
        VStack(spacing: 20) {
            // PIN Gösterimi
            HStack(spacing: 15) {
                ForEach(0..<6) { index in
                    PINDigitView(digit: getDigit(at: index))
                }
            }
            
            // PIN Girişi
            CustomTextField(
                placeholder: "6 haneli PIN kodunu girin",
                text: $pin
            )
            .keyboardType(.numberPad)
            #if compiler(>=5.9)
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count > 6 {
                    pin = String(newValue.prefix(6))
                }
            }
            #else
            .onChange(of: pin) { value in
                if value.count > 6 {
                    pin = String(value.prefix(6))
                }
            }
            #endif
        }
    }
    
    private func getDigit(at index: Int) -> String {
        let pinArray = Array(pin)
        return index < pinArray.count ? "●" : ""
    }
}

// PIN Digit Görünümü
struct PINDigitView: View {
    let digit: String
    
    var body: some View {
        Text(digit)
            .font(.system(size: 24, weight: .bold))
            .frame(width: 45, height: 45)
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
