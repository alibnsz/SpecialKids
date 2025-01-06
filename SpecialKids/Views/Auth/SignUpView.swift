import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var acceptTerms = false
    @State private var selectedRole = "parent"
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showTeacherExpertise = false
    @State private var showParentView = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showTermsSheet = false
    @State private var showAddChildView = false
    
    var roles = [
        ("parent", "Ebeveyn"),
        ("teacher", "Öğretmen/Uzman")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo veya Başlık
                Text("Kayıt Ol")
                    .font(.custom("Outfit-ExtraBold", size: 28))
                    .padding(.top, 30)
                
                VStack(spacing: 20) {
                    // Ad Soyad
                    CustomTextField(placeholder: "Ad Soyad", text: $fullName)
                    
                    // Email
                    CustomTextField(placeholder: "E-posta", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    // Telefon Numarası
                    CustomTextField(placeholder: "Telefon Numarası", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    // Şifre alanı
                    ZStack(alignment: .trailing) {
                        CustomTextField(
                            placeholder: "Şifre",
                            text: $password,
                            isSecure: !showPassword
                        )
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                    
                    // Şifre tekrar alanı
                    ZStack(alignment: .trailing) {
                        CustomTextField(
                            placeholder: "Şifreyi Tekrar Giriniz",
                            text: $confirmPassword,
                            isSecure: !showConfirmPassword
                        )
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                    
                    if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Şifreler eşleşmiyor")
                            .font(.custom("Outfit-Regular", size: 12))
                            .foregroundColor(.red)
                    }
                    
                    // Kullanım şartları
                    Toggle(isOn: $acceptTerms) {
                        HStack(spacing: 4) {
                            Text("Kullanım şartlarını ")
                                .font(.custom("Outfit-Regular", size: 12))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showTermsSheet = true
                            }) {
                                Text("okudum ve kabul ediyorum")
                                    .font(.custom("Outfit-Medium", size: 12))
                                    .foregroundColor(Color("Plum"))
                            }
                        }
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.horizontal, 4)
                    
                    // Rol Seçimi - Yeni animasyonlu seçici
                    AnimatedRoleSelector(selectedRole: $selectedRole)
                        .padding(.top, 10)
                    CustomButtonView(title: "Kayit Ol", isLoading: isLoading, disabled: !isFormValid, type: .primary) {
                        signUp()
                    }
                    
                    Spacer()
                    // Giriş Yap Linki
                    HStack {
                        Text("Zaten hesabınız var mı?")
                            .font(.custom("Outfit-Regular", size: 16))
                            .foregroundColor(.gray)
                        
                        Button(action: { dismiss() }) {
                            Text("Giriş Yap")
                                .font(.custom("Outfit-Medium", size: 16))
                                .foregroundColor(Color("Plum"))
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            }
        }
        .fullScreenCover(isPresented: $showTeacherExpertise) {
            TeacherExpertiseView(userId: Auth.auth().currentUser?.uid ?? "")
        }
        .fullScreenCover(isPresented: $showParentView) {
            ParentView()
        }
        .fullScreenCover(isPresented: $showAddChildView) {
            AddChildView()
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsOfServiceView()
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !fullName.isEmpty &&
        !phoneNumber.isEmpty &&
        password.count >= 6 &&
        email.contains("@") &&
        password == confirmPassword &&
        acceptTerms
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
                            showParentView = false
                            showAddChildView = true
                        }
                    }
                }
            }
        }
    }
}

// RoleSelectionButton yerine yeni bir AnimatedRoleSelector ekleyelim
struct AnimatedRoleSelector: View {
    @Binding var selectedRole: String
    let roles = [
        ("parent", "Ebeveyn", "person.fill"),
        ("teacher", "Öğretmen/Uzman", "person.fill.checkmark")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hesap Türü")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.black.opacity(0.6))
            
            ZStack {
                // Arka plan
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Plum").opacity(0.2))
                
                // Seçili olan için kaydırılan mavi arka plan
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Plum"))
                        .frame(width: geometry.size.width / 2)
                        .offset(x: selectedRole == "parent" ? 0 : geometry.size.width / 2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedRole)
                }
                
                // Butonlar
                HStack(spacing: 0) {
                    ForEach(roles, id: \.0) { role in
                        Button(action: {
                            withAnimation {
                                selectedRole = role.0
                            }
                        }) {
                            HStack {
                                Image(systemName: role.2)
                                    .font(.custom("Outfit-Medium", size: 14))
                                Text(role.1)
                                    .font(.custom("Outfit-Medium", size: 14))
                            }
                            .foregroundColor(selectedRole == role.0 ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                        }
                    }
                }
            }
            .frame(height: 45)
        }
    }
}

// Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? Color("Plum") : .gray)
                    .font(.system(size: 20))
                    .frame(width: 20, height: 20)
                
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SignUpView()
} 
