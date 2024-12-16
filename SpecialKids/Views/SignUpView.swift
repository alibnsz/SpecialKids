import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var selectedRole = "parent"
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showTeacherExpertise = false
    @State private var showParentView = false
    
    var roles = [
        ("parent", "Ebeveyn"),
        ("teacher", "Öğretmen/Uzman")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo veya Başlık
                Text("Kayıt Ol")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 30)
                
                VStack(spacing: 20) {
                    // Ad Soyad
                    CustomTextField(placeholder: "Ad Soyad", text: $fullName)
                    
                    // Email
                    CustomTextField(placeholder: "E-posta", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    // Şifre
                    CustomTextField(placeholder: "Şifre", text: $password)
                        .textInputAutocapitalization(.never)
                    
                    // Rol Seçimi
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hesap Türü")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                        
                        HStack(spacing: 15) {
                            ForEach(roles, id: \.0) { role in
                                RoleSelectionButton(
                                    title: role.1,
                                    isSelected: selectedRole == role.0,
                                    action: { selectedRole = role.0 }
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    CustomButton(title: "Kayit Ol", backgroundColor: Color("BittersweetOrange")) {
                        signUp()
                    }
  
                    
                    // Giriş Yap Linki
                    HStack {
                        Text("Zaten hesabınız var mı?")
                            .foregroundColor(.gray)
                        
                        Button(action: { dismiss() }) {
                            Text("Giriş Yap")
                                .foregroundColor(Color("BittersweetOrange"))
                        }
                    }
                    .font(.system(size: 14))
                }
                .padding(.horizontal,20)
            }
        }
        .fullScreenCover(isPresented: $showTeacherExpertise) {
            TeacherExpertiseView(userId: Auth.auth().currentUser?.uid ?? "")
        }
        .fullScreenCover(isPresented: $showParentView) {
            ParentView()
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !fullName.isEmpty && 
        password.count >= 6 &&
        email.contains("@")
    }
    
    private func signUp() {
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                guard let user = result?.user else { return }
                
                let userData: [String: Any] = [
                    "name": fullName,
                    "email": email,
                    "createdAt": Timestamp(),
                    "uid": user.uid
                ]
                
                let db = Firestore.firestore()
                
                // Role göre farklı koleksiyonlara kaydet
                let collectionName = selectedRole == "teacher" ? "teachers" : "parents"
                
                db.collection(collectionName).document(user.uid).setData(userData) { error in
                    DispatchQueue.main.async {
                        isLoading = false
                        
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showError = true
                            return
                        }
                        
                        if selectedRole == "teacher" {
                            showTeacherExpertise = true
                        } else {
                            showParentView = true
                        }
                    }
                }
            }
        }
    }
}

// Rol Seçim Butonu
struct RoleSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

#Preview {
    SignUpView()
} 
