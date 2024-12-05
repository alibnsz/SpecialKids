import SwiftUI

struct AddStudentSheet: View {
    let schoolClass: SchoolClass
    @State private var studentId = ""
    @State private var errorMessage = ""
    var onAddStudent: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Öğrenci ID'si")
                    .font(.custom(outfitMedium, size: 24))
                
                Text("Lütfen 6 haneli öğrenci ID'sini giriniz. 😊")
                    .font(.custom(outfitLight, size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                CustomTextField(placeholder: "Öğrenci ID", backgroundColor: .white, text: $studentId)
                    .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.custom(outfitLight, size: 14))
                }
                
                CustomButton(title: "Ekle", backgroundColor: Color("MandyPink")) {
                    addStudent()
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitle("Öğrenci Ekle", displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            print("AddStudentSheet appeared for class: \(schoolClass.name)")
        }
    }
    
    private func addStudent() {
        print("Adding student with ID: \(studentId)")
        guard !studentId.isEmpty else {
            errorMessage = "Öğrenci ID'si boş olamaz."
            return
        }
        
        FirebaseManager.shared.getStudentById(id: studentId) { student in
            if let student = student {
                print("Student found: \(student.name)")
                FirebaseManager.shared.addStudentToClass(classId: schoolClass.id, studentId: student.id) { error in
                    if let error = error {
                        print("Error adding student to class: \(error.localizedDescription)")
                        errorMessage = "Öğrenci eklenirken bir hata oluştu."
                    } else {
                        print("Student added successfully")
                        onAddStudent()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                print("Student not found")
                errorMessage = "Öğrenci bulunamadı."
            }
        }
    }
}
