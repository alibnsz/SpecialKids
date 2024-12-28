import SwiftUI
import FirebaseFirestore

struct TeacherSettingsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var teacherName: String = ""
    @State private var teacherEmail: String = ""
    @State private var teacherPhone: String = ""
    @State private var showEditProfileSheet = false
    @State private var showLogoutAlert = false
    @State private var showExpertiseSheet = false
    
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profil Kartı
                ProfileCard(
                    name: teacherName,
                    email: teacherEmail,
                    phone: teacherPhone
                )
                .padding(.horizontal, horizontalPadding)
                
                // Ayarlar Bölümleri
                VStack(spacing: 8) {
                    SettingsSection(title: "Hesap") {
                        SettingsRow(icon: "person.fill", title: "Profili Düzenle", color: .blue) {
                            showEditProfileSheet = true
                        }
                        
                        SettingsRow(icon: "brain.head.profile", title: "Uzmanlık Alanları", color: .purple) {
                            showExpertiseSheet = true
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
            fetchTeacherProfile()
        }
        .sheet(isPresented: $showEditProfileSheet) {
            TeacherEditProfileSheet(
                teacherName: $teacherName,
                teacherEmail: $teacherEmail,
                teacherPhone: $teacherPhone
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showExpertiseSheet) {
            TeacherExpertiseView(userId: firebaseManager.auth.currentUser?.uid ?? "")
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
    
    private func fetchTeacherProfile() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("teachers")
            .document(userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    self.teacherName = data["name"] as? String ?? ""
                    self.teacherEmail = data["email"] as? String ?? ""
                    self.teacherPhone = data["phone"] as? String ?? ""
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

// MARK: - Teacher Edit Profile Sheet
struct TeacherEditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var teacherName: String
    @Binding var teacherEmail: String
    @Binding var teacherPhone: String
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempPhone: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Ad Soyad",
                        text: $tempName
                    )
                    
                    CustomTextField(
                        placeholder: "E-posta",
                        text: $tempEmail
                    )
                    .disabled(true)
                    
                    CustomTextField(
                        placeholder: "Telefon",
                        text: $tempPhone
                    )
                    .keyboardType(.phonePad)
                }
                .padding(.horizontal)
                
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
                tempName = teacherName
                tempEmail = teacherEmail
                tempPhone = teacherPhone
            }
        }
    }
    
    private func updateProfile() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("teachers")
            .document(userId)
            .updateData([
                "name": tempName,
                "email": tempEmail,
                "phone": tempPhone
            ]) { error in
                if error == nil {
                    teacherName = tempName
                    teacherEmail = tempEmail
                    teacherPhone = tempPhone
                    dismiss()
                }
            }
    }
}

