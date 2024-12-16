import SwiftUI

struct AddStudentSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var studentId = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    let schoolClass: SchoolClass
    var onStudentAdded: () -> Void
    
    var isFormValid: Bool {
        !studentId.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Öğrenci ID'si Girin")
                .font(.headline)
            
            CustomTextField(placeholder: "Öğrenci ID", text: $studentId)
                .textInputAutocapitalization(.never)
            
            CustomButtonView(
                title: "Ekle",
                isLoading: isLoading,
                disabled: !isFormValid,
                type: .secondary
            ) {
                addStudent()
            }
        }
        .padding()
        .alert("Bilgi", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) {
                if !alertMessage.contains("hata") {
                    onStudentAdded()
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addStudent() {
        isLoading = true
        
        FirebaseManager.shared.addStudentToClass(classId: schoolClass.id, studentId: studentId) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Öğrenci başarıyla eklendi"
            }
            showAlert = true
        }
    }
}
#Preview {
    ClassView()
}
