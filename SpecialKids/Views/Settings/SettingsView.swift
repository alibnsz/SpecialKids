import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var parentName: String = ""
    @State private var parentEmail: String = ""
    @State private var parentPhone: String = ""
    @State private var showEditProfileSheet = false
    @State private var showPremiumSheet = false
    @State private var showLogoutAlert = false
    
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profil Kartı
                ProfileCard(name: parentName, email: parentEmail, phone: parentPhone)
                    .padding(.horizontal, horizontalPadding)
                
                // Ayarlar Bölümleri
                VStack(spacing: 8) {
                    SettingsSection(title: "Hesap") {
                        SettingsRow(icon: "person.fill", title: "Profili Düzenle", color: .blue) {
                            showEditProfileSheet = true
                        }
                        
                        SettingsRow(icon: "crown.fill", title: "Premium'a Geç", color: .yellow) {
                            showPremiumSheet = true
                        }
                    }
                    
                    SettingsSection(title: "Uygulama") {
                        SettingsRow(icon: "bell.fill", title: "Bildirimler", color: .red) {
                            // Bildirim ayarları
                        }
                        
                        SettingsRow(icon: "lock.fill", title: "Gizlilik", color: .gray) {
                            // Gizlilik ayarları
                        }
                    }
                    
                    SettingsSection(title: "Diğer") {
                        SettingsRow(icon: "star.fill", title: "Uygulamayı Değerlendir", color: .orange) {
                            // App Store'a yönlendir
                        }
                        
                        SettingsRow(icon: "envelope.fill", title: "İletişim", color: .green) {
                            // İletişim sayfası
                        }
                        
                        Button {
                            showLogoutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Çıkış Yap")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .padding(.top, 16)
        }
        .background(Color.gray.opacity(0.05))
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            fetchParentProfile()
        }
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileSheet(parentName: $parentName, parentEmail: $parentEmail, parentPhone: $parentPhone)
                .presentationDetents([.medium])
        }
        .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
            Button("İptal", role: .cancel) {}
            Button("Çıkış Yap", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
        }
    }
    
    private func fetchParentProfile() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("parents")
            .document(userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    self.parentName = data["name"] as? String ?? ""
                    self.parentEmail = data["email"] as? String ?? ""
                    self.parentPhone = data["phone"] as? String ?? ""
                }
            }
    }
    
    private func signOut() {
        do {
            try firebaseManager.auth.signOut()
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "userRole")
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

// MARK: - Profile Card
struct ProfileCard: View {
    let name: String
    let email: String
    let phone: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Profil resmi
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color("BittersweetOrange"))
            
            // İsim, email ve telefon
            VStack(spacing: 4) {
                Text(name)
                    .font(.custom("Outfit-SemiBold", size: 24))
                Text(email)
                    .font(.custom("Outfit-Regular", size: 16))
                    .foregroundColor(.secondary)
                if !phone.isEmpty {
                    Text(phone)
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Outfit-SemiBold", size: 18))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding()
            .background(Color.white)
        }
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var parentName: String
    @Binding var parentEmail: String
    @Binding var parentPhone: String
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempPhone: String = ""
    
    init(parentName: Binding<String>, parentEmail: Binding<String>, parentPhone: Binding<String>) {
        _parentName = parentName
        _parentEmail = parentEmail
        _parentPhone = parentPhone
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profil düzenleme alanları
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Ad Soyad",
                        text: $tempName
                    )
                    
                    CustomTextField(
                        placeholder: "E-posta",
                        text: $tempEmail
                    )
                    
                    CustomTextField(
                        placeholder: "Telefon",
                        text: $tempPhone
                    )
                    .keyboardType(.phonePad)
                }
                .padding(.horizontal)
                
                // Kaydet butonu
                CustomButtonView(
                    title: "Kaydet",
                    disabled: tempName.isEmpty,
                    type: .primary
                ) {
                    updateProfile()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("BittersweetOrange"))
                }
            }
            .background(.white)
            .onAppear {
                tempName = parentName
                tempEmail = parentEmail
                tempPhone = parentPhone
            }
        }
    }
    
    private func updateProfile() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("parents")
            .document(userId)
            .updateData([
                "name": tempName,
                "email": tempEmail,
                "phone": tempPhone
            ]) { error in
                if error == nil {
                    parentName = tempName
                    parentEmail = tempEmail
                    parentPhone = tempPhone
                    dismiss()
                }
            }
    }
} 
