import SwiftUI
import FirebaseFirestore

struct TeacherExpertiseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var university = ""
    @State private var graduationYear = ""
    @State private var experience = ""
    @State private var specialization = ""
    @State private var certificates: [String] = [""]
    @State private var isLoading = false
    @State private var showTeacherHome = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let userId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Uzman Bilgileri")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    // Temel Bilgiler
                    CustomTextField(placeholder: "Üniversite", text: $university)
                    
                    CustomTextField(placeholder: "Mezuniyet Yılı", text: $graduationYear)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(placeholder: "Deneyim (Yıl)", text: $experience)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(placeholder: "Uzmanlık Alanı", text: $specialization)
                }
                
                // Sertifikalar Bölümü
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Sertifikalar(Zorunlu Degil) ")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(certificates.indices, id: \.self) { index in
                            CustomTextField(
                                placeholder: "Sertifika \(index + 1)",
                                text: $certificates[index]
                            )
                        }
                    }
                    
                    Button(action: {
                        certificates.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Sertifika Ekle")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 8)
                
                CustomButton(title: "Kaydet ve Devam Et", backgroundColor: Color("BittersweetOrange")) {
                    saveTeacherInfo()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showTeacherHome) {
            ClassView()
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !university.isEmpty &&
        !graduationYear.isEmpty &&
        !experience.isEmpty &&
        !specialization.isEmpty &&
        Int(graduationYear) != nil &&
        Int(experience) != nil
    }
    
    private func saveTeacherInfo() {
        guard isFormValid else {
            errorMessage = "Lütfen tüm alanları doğru şekilde doldurun"
            showError = true
            return
        }
        
        isLoading = true
        
        guard let graduationYearInt = Int(graduationYear),
              let experienceInt = Int(experience) else {
            errorMessage = "Lütfen geçerli sayısal değerler girin"
            showError = true
            isLoading = false
            return
        }
        
        let teacherData: [String: Any] = [
            "university": university,
            "graduationYear": graduationYearInt,
            "experience": experienceInt,
            "specialization": specialization,
            "certificates": certificates.filter { !$0.isEmpty },
            "updatedAt": Timestamp()
        ]
        
        let db = Firestore.firestore()
        db.collection("teachers").document(userId).setData(teacherData, merge: true) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                showTeacherHome = true
            }
        }
    }
}

#Preview {
    TeacherExpertiseView(userId: "preview")
} 
