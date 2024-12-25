import SwiftUI

struct HomeworkSheet: View {
    let student: Student
    @Environment(\.dismiss) private var dismiss
    @State private var homeworkTitle = ""
    @State private var homeworkDescription = ""
    @State private var dueDate = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessAnimation = false
    
    var isFormValid: Bool {
        !homeworkTitle.isEmpty && !homeworkDescription.isEmpty
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                StudentInfoSection(student: student)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Ödev Detayları")
                        .font(.custom("Outfit-Bold", size: 20))
                        .foregroundColor(Color("OilBlack"))
                    
                    // Başlık
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Başlık")
                            .font(.custom("Outfit-Medium", size: 14))
                            .foregroundColor(.gray)
                        CustomTextField(
                            placeholder: "Ödev başlığını girin",
                            text: $homeworkTitle
                        )
                    }
                    
                    // Açıklama
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Açıklama")
                            .font(.custom("Outfit-Medium", size: 14))
                            .foregroundColor(.gray)
                        TextEditor(text: $homeworkDescription)
                            .font(.custom("Outfit-Regular", size: 16))
                            .frame(height: 120)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if homeworkDescription.isEmpty {
                                        Text("Ödev açıklamasını girin")
                                            .font(.custom("Outfit-Regular", size: 16))
                                            .foregroundColor(.gray)
                                            .padding(.leading, 16)
                                            .padding(.top, 16)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    // Teslim Tarihi
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Teslim Tarihi")
                            .font(.custom("Outfit-Medium", size: 14))
                            .foregroundColor(.gray)
                        DatePicker(
                            "",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .font(.custom("Outfit-Regular", size: 16))
                        .accentColor(Color("OilBlack"))
                    }
                    
                    CustomButtonView(
                        title: "Ödev Gönder",
                        isLoading: isLoading,
                        disabled: !isFormValid,
                        type: .primary
                    ) {
                        sendHomework()
                    }
                    .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .navigationTitle("Ödev Ver")
        .navigationBarTitleDisplayMode(.inline)
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
    
    private func sendHomework() {
        isLoading = true
        
        let homework = Homework(
            title: homeworkTitle,
            description: homeworkDescription,
            dueDate: dueDate,
            studentId: student.id,
            status: .pending
        )
        
        FirebaseManager.shared.assignHomework(homework: homework) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Ödev gönderilirken hata oluştu: \(error.localizedDescription)"
            } else {
                alertMessage = "Ödev başarıyla gönderildi!"
                showSuccessAnimation = true
            }
            showAlert = true
        }
    }
}

// MARK: - Supporting Views
struct StudentInfoSection: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Öğrenci Bilgileri")
                .font(.custom("Outfit-Bold", size: 20))
                .foregroundColor(Color("OilBlack"))
            
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color("OilBlack"))
                Text(student.name)
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("OilBlack"))
            }
            
            HStack(spacing: 12) {
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color("OilBlack"))
                Text("ID: \(student.studentId)")
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(Color.gray.opacity(0.8))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct HomeworkFormSection: View {
    @Binding var homeworkTitle: String
    @Binding var homeworkDescription: String
    @Binding var dueDate: Date
    let isLoading: Bool
    let isFormValid: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ödev Detayları")
                .font(.custom("Outfit-Bold", size: 20))
                .foregroundColor(Color("OilBlack"))
            
            FormField(title: "Başlık") {
                CustomTextField(
                    placeholder: "Ödev başlığını girin",
                    text: $homeworkTitle
                )
            }
            
            FormField(title: "Açıklama") {
                CustomTextField(
                    placeholder: "Ödev açıklamasını girin",
                    text: $homeworkDescription,
                    isMultiline: true
                )
                .frame(height: 100)
            }
            
            FormField(title: "Teslim Tarihi") {
                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .font(.custom("Outfit-Regular", size: 16))
                .accentColor(Color("OilBlack"))
            }
            
            CustomButtonView(
                title: "Ödev Gönder",
                isLoading: isLoading,
                disabled: !isFormValid,
                type: .primary,
                action: onSubmit
            )
            .padding(.top, 8)
        }
    }
}

struct FormField<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(Color.gray.opacity(0.8))
            content
        }
    }
}

struct CloseButton: View {
    let action: DismissAction
    
    var body: some View {
        Button(action: { action() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color("OilBlack"))
        }
    }
}
