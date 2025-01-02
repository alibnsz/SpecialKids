
import SwiftUI

struct AddClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var className = ""
    @State private var isLoading = false
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Sınıf adı alanı
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sınıf Adı")
                        .font(.custom("Outfit-Medium", size: 14))
                        .foregroundColor(.secondary)
                    
                    CustomTextField(
                        placeholder: "Sınıf adını girin",
                        text: $className
                    )
                }
                
                CustomButtonView(
                    title: "Sınıf Oluştur",
                    isLoading: isLoading,
                    disabled: className.isEmpty,
                    type: .primary
                ) {
                    createClass()
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Yeni Sınıf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("Plum"))
                }
            }
        }
    }
    
    private func createClass() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        isLoading = true
        
        firebaseManager.createClass(name: className, teacherId: teacherId) { error in
            isLoading = false
            if error == nil {
                dismiss()
            }
        }
    }
} 
