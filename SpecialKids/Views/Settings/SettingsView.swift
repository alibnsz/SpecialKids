import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var showLogoutAlert = false
    @State private var showEditProfileSheet = false
    @State private var showExpertiseSheet = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Profil Kartı
                    ParentProfileCard(
                        email: firebaseManager.auth.currentUser?.email ?? "",
                        onEditTap: { showEditProfileSheet = true }
                    )
                    // MARK: - Premium Kartı
                    ParentPremiumCard()
                    
                    // MARK: - Ayarlar Grupları
                    VStack(spacing: 20) {
                        // Uygulama Ayarları
                        ParentSettingsGroup(title: "Uygulama") {
                            ParentSettingsRow(
                                icon: "bell.fill",
                                title: "Bildirimler",
                                color: Color("Plum")
                            ) {
                                NavigationLink {
                                    NotificationSettingsView()
                                } label: {
                                    ParentSettingsNavigationLabel()
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 44)
                            
                            ParentSettingsRow(
                                icon: "moon.fill",
                                title: "Karanlık Mod",
                                color: Color("Plum")
                            ) {
                                Toggle("", isOn: $isDarkMode)
                                    .tint(Color("Plum"))
                                    .scaleEffect(0.8)
                            }
                            
                            Divider()
                                .padding(.leading, 44)
                            
                            ParentSettingsRow(
                                icon: "globe",
                                title: "Dil",
                                color: Color("Plum")
                            ) {
                                Text("Türkçe")
                                    .font(.custom("Outfit-Regular", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .padding(.leading, 44)
                            
                            ParentSettingsRow(
                                icon: "questionmark.circle.fill",
                                title: "Yardım",
                                color: Color("Plum")
                            ) {
                                NavigationLink {
                                    HelpView()
                                } label: {
                                    ParentSettingsNavigationLabel()
                                }
                            }
                        }
                    }
                    
                    // MARK: - Çıkış Yap Butonu
                    ParentLogoutButton(showAlert: $showLogoutAlert)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
                Button("İptal", role: .cancel) {}
                Button("Çıkış Yap", role: .destructive) {
                    firebaseManager.signOut()
                }
            } message: {
                Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
            }
        }
    }
}

// MARK: - Profile Card
struct ParentProfileCard: View {
    let email: String
    let onEditTap: () -> Void
    @State private var parentInfo: ParentInfo?
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Profil Resmi ve İsim
            ZStack(alignment: .bottomTrailing) {
                // Büyük arka plan dairesi

                
                // Profil resmi
                Circle()
                    .fill(Color("Plum").opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person")
                            .font(.system(size: 32))
                            .foregroundColor(Color("Plum"))
                    )
                
                // Düzenle butonu
                Button(action: onEditTap) {
                    Circle()
                        .fill(Color("Plum"))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                }
                .offset(x: 8, y: 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            // MARK: - Kullanıcı Bilgileri
            VStack(spacing: 4) {
                if let name = parentInfo?.name {
                    Text(name)
                        .font(.custom("Outfit-SemiBold", size: 18))
                        .foregroundColor(Color("NeutralBlack"))
                }
                
                Text(email)
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .onAppear {
            fetchTeacherInfo()
        }
    }
    
    private func fetchTeacherInfo() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.db.collection("parents")
            .document(userId)
            .getDocument { document, error in
                if let data = document?.data() {
                    self.parentInfo = ParentInfo(
                        name: data["name"] as? String ?? ""
                    )
                }
            }
    }
}

// MARK: - Teacher Info Model
struct ParentInfo {
    let name: String
}
// MARK: - Premium Card
struct ParentPremiumCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("FantasyPink"))
                
                Text("Premium")
                    .font(.custom("Outfit-Bold", size: 18))
                    .foregroundColor(Color("NeutralBlack"))
            }
            
            Text("Sınırsız özellikler için premium'a geçin")
                .font(.custom("Outfit-Regular", size: 14))
                .foregroundColor(.secondary)
            
            Button {
                // Premium action
            } label: {
                Text("Premium'a Geç")
                    .font(.custom("Outfit-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("Plum"))
                    .cornerRadius(12)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
    }
}

// MARK: - Logout Button
struct ParentLogoutButton: View {
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Çıkış Yap")
                    .font(.custom("Outfit-SemiBold", size: 16))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color("DarkPurple"), Color("Plum")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color("DarkPurple").opacity(0.3), radius: 10, y: 5)
        }
    }
}

// MARK: - Settings Group
struct ParentSettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Outfit-SemiBold", size: 20))
                .foregroundColor(Color("NeutralBlack"))
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
            )
        }
    }
}

// MARK: - Settings Navigation Label
struct ParentSettingsNavigationLabel: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary)
    }
}

// MARK: - Settings Row
struct ParentSettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
            // İkon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            }
            
            // Başlık
            Text(title)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(Color("NeutralBlack"))
            
            Spacer()
            
            // İçerik
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


