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
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    StudentProfileCard(student: student)
                    HomeworkDetailsCard(
                        title: $homeworkTitle,
                        description: $homeworkDescription,
                        dueDate: $dueDate
                    )
                    SubmitButton(
                        isLoading: isLoading,
                        isFormValid: isFormValid,
                        action: sendHomework
                    )
                }
                .padding(20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Yeni Ödev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton(dismiss: dismiss)
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
    
    private func sendHomework() {
        isLoading = true
        
        FirebaseManager.shared.fetchParentForStudent(studentId: student.studentId) { parentId in
            guard let parentId = parentId else {
                self.isLoading = false
                self.alertMessage = "Öğrencinin velisi bulunamadı"
                self.showAlert = true
                return
            }
            
            let homework = Homework(
                id: UUID().uuidString,
                title: self.homeworkTitle,
                description: self.homeworkDescription,
                dueDate: self.dueDate,
                studentId: self.student.id,
                teacherId: FirebaseManager.shared.auth.currentUser?.uid,
                status: .pending,
                assignedDate: Date()
            )
            
            FirebaseManager.shared.assignHomework(homework: homework) { error in
                self.isLoading = false
                
                if let error = error {
                    self.alertMessage = "Ödev gönderilirken hata oluştu: \(error.localizedDescription)"
                } else {
                    Task {
                        await FirebaseManager.shared.sendHomeworkNotification(
                            homework: homework,
                            parentId: parentId
                        )
                    }
                    self.alertMessage = "Ödev başarıyla gönderildi!"
                    self.showSuccessAnimation = true
                }
                self.showAlert = true
            }
        }
    }
}

// MARK: - Student Profile Card
struct StudentProfileCard: View {
    let student: Student
    
    var body: some View {
        VStack(spacing: 16) {
            ProfileImage()
            StudentInfo(student: student)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15)
        )
    }
}

struct ProfileImage: View {
    var body: some View {
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
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color("Plum"))
        }
    }
}

struct StudentInfo: View {
    let student: Student
    
    var body: some View {
        VStack(spacing: 8) {
            Text(student.name)
                .font(.custom("Outfit-SemiBold", size: 20))
                .foregroundColor(Color("NeutralBlack"))
            
            Text("Öğrenci ID: \(student.studentId)")
                .font(.custom("Outfit-Regular", size: 14))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Homework Details Card
struct HomeworkDetailsCard: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var dueDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Ödev Detayları")
                .font(.custom("Outfit-Bold", size: 20))
                .foregroundColor(Color("NeutralBlack"))
            
            TitleField(title: $title)
            DescriptionField(description: $description)
            DueDateField(dueDate: $dueDate)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15)
        )
    }
}

struct TitleField: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Başlık")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            CustomTextField(
                placeholder: "Ödev başlığını girin",
                text: $title
            )
        }
    }
}

struct DescriptionField: View {
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Açıklama")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            TextEditor(text: $description)
                .font(.custom("Outfit-Regular", size: 16))
                .frame(height: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Plum").opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("Plum").opacity(0.1), lineWidth: 1)
                        )
                )
                .overlay(
                    Group {
                        if description.isEmpty {
                            Text("Ödev açıklamasını detaylı bir şekilde yazın...")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.leading, 16)
                                .padding(.top, 20)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}

struct DueDateField: View {
    @Binding var dueDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Teslim Tarihi")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color("Plum"))
                
                DatePicker(
                    "",
                    selection: $dueDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .accentColor(Color("Plum"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Plum").opacity(0.05))
            )
        }
    }
}

// MARK: - Supporting Views
struct SubmitButton: View {
    let isLoading: Bool
    let isFormValid: Bool
    let action: () -> Void
    
    var body: some View {
        CustomButtonView(
            title: "Ödev Gönder",
            isLoading: isLoading,
            disabled: !isFormValid,
            type: .primary,
            action: action
        )
        .padding(.top, 8)
    }
}

struct CloseButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button("Kapat") {
            dismiss()
        }
        .font(.custom("Outfit-Medium", size: 16))
        .foregroundColor(Color("Plum"))
    }
}
