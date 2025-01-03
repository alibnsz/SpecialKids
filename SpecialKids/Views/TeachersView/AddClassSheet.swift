import SwiftUI

struct AddClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var className = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var isFormValid: Bool {
        !className.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Header
            VStack(spacing: 16) {
                // İkon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("DarkPurple").opacity(0.1),
                                    Color("Plum").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(Color("Plum"))
                }
                
                Text("Yeni Sınıf Oluştur")
                    .font(.custom("Outfit-Bold", size: 24))
                    .foregroundColor(Color("NeutralBlack"))
                
                Text("Sınıfınıza bir isim vererek başlayın")
                    .font(.custom("Outfit-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            
            // MARK: - Input Card
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sınıf Adı")
                        .font(.custom("Outfit-Medium", size: 14))
                        .foregroundColor(.secondary)
                    
                    CustomTextField(
                        placeholder: "Örn: 3-A Sınıfı",
                        text: $className
                    )
                }
                
                CustomButtonView(
                    title: "Sınıfı Oluştur",
                    isLoading: isLoading,
                    disabled: !isFormValid,
                    type: .primary
                ) {
                    createClass()
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 15)
            )
        }
        .padding(20)
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {
                if !alertMessage.contains("hata") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createClass() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        isLoading = true
        
        firebaseManager.createClass(name: className, teacherId: teacherId) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Sınıf başarıyla oluşturuldu"
            }
            showAlert = true
        }
    }
}

#Preview {
    AddClassSheet()
} 
