import SwiftUI

struct AddStudentToClassSheet: View {
    let classId: String
    @Environment(\.dismiss) private var dismiss
    @State private var studentId = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                            
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(Color("Plum"))
                        }
                        
                        Text("Öğrenci Ekle")
                            .font(.custom("Outfit-Bold", size: 24))
                            .foregroundColor(Color("NeutralBlack"))
                        
                        Text("Öğrencinin ID'sini girerek sınıfa ekleyebilirsiniz")
                            .font(.custom("Outfit-Regular", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // MARK: - Input Card
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Öğrenci ID")
                                .font(.custom("Outfit-Medium", size: 14))
                                .foregroundColor(.secondary)
                            
                            CustomTextField(
                                placeholder: "Öğrenci ID'sini girin",
                                text: $studentId
                            )
                        }
                        
                        CustomButtonView(
                            title: "Öğrenci Ekle",
                            isLoading: isLoading,
                            disabled: studentId.isEmpty,
                            type: .primary
                        ) {
                            addStudent()
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
            }
            .background(Color.gray.opacity(0.05))
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
    }
    
    private func addStudent() {
        isLoading = true
        
        firebaseManager.addStudentToClass(classId: classId, studentId: studentId) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Hata: \(error.localizedDescription)"
            } else {
                alertMessage = "Öğrenci başarıyla eklendi"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
            showAlert = true
        }
    }
} 
