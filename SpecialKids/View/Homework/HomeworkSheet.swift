import SwiftUI

struct HomeworkSheet: View {
    let student: Student
    @Binding var homeworkTitle: String
    @Binding var homeworkDescription: String
    @State private var isHomeworkSent = false
    @State private var showAnimation = false
    @State private var dueDate = Date()
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    studentInfoSection
                    homeworkFormSection
                    if showAnimation {
                        LottieView(name: "success")
                            .frame(width: 200, height: 200)
                    }
                }
                .padding()
            }
            .navigationTitle("Ödev Ver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }

    private var studentInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Öğrenci Bilgileri")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading) {
                    InfoRow(title: "Ad", value: student.name)
                    InfoRow(title: "ID", value: student.id)
                    InfoRow(title: "Yaş", value: "\(student.age)")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))

    }

    private var homeworkFormSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ödev Detayları")
                .font(.title2)
                .fontWeight(.bold)
            
            CustomTextField(placeholder: "Odev Basligi", text: $homeworkTitle)
            TextEditor(text: $homeworkDescription)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            DatePicker("Teslim Tarihi", selection: $dueDate, displayedComponents: .date)

            CustomButton(title: "Gonder", backgroundColor: Color("OilBlack")) {
                sendHomework()
            }
        }
        .padding()
        .background(Color(.systemBackground))

    }
    private func sendHomework() {
        guard !homeworkTitle.isEmpty, !homeworkDescription.isEmpty else {
            alertMessage = "Ödev başlığı ve açıklaması boş olamaz!"
            showAlert = true
            return
        }

        let homework = Homework(id: UUID().uuidString, title: homeworkTitle, description: homeworkDescription, dueDate: dueDate, studentId: student.id)

        FirebaseManager.shared.assignHomework(homework: homework) { error in
            if let error = error {
                alertMessage = "Ödev gönderilirken hata oluştu: \(error.localizedDescription)"
                showAlert = true
            } else {
                isHomeworkSent = true
                showAnimation = true
                alertMessage = "Ödev başarıyla gönderildi!"
                showAlert = true
                // Reset form
                homeworkTitle = ""
                homeworkDescription = ""
                dueDate = Date()
                // Hide animation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showAnimation = false
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .fontWeight(.medium)
            Text(value)
                .fontWeight(.regular)
        }
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        // Here you would typically set up your Lottie animation
        // For this example, we'll just use a placeholder
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update the view if needed
    }
}
