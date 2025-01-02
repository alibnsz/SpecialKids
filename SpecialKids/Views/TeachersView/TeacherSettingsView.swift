import SwiftUI
import FirebaseAuth

struct TeacherSettingsView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var showLogoutAlert = false
    @State private var showEditProfileSheet = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Profil Kartı
                    VStack(spacing: 20) {
                        // Profil Resmi
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color("Plum").opacity(0.1),
                                            Color("FantasyPink").opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color("Plum"))
                        }
                        
                        // Kullanıcı Bilgileri
                        VStack(spacing: 8) {
                            Text(firebaseManager.auth.currentUser?.email ?? "Öğretmen")
                                .font(.custom("Outfit-SemiBold", size: 20))
                                .foregroundColor(Color("NeutralBlack"))
                            
                            Text("Öğretmen")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        // Düzenle Butonu
                        Button {
                            showEditProfileSheet = true
                        } label: {
                            Text("Profili Düzenle")
                                .font(.custom("Outfit-Medium", size: 14))
                                .foregroundColor(Color("Plum"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Plum").opacity(0.1))
                                )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 15)
                    )
                    
                    // MARK: - Ayarlar Listesi
                    VStack(spacing: 8) {
                        // Bildirimler
                        TeacherSettingsRow(
                            icon: "bell.fill",
                            title: "Bildirimler",
                            color: Color("FantasyPink")
                        ) {
                            NavigationLink {
                                NotificationSettingsView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Mod
                        TeacherSettingsRow(
                            icon: "moon.fill",
                            title: "Karanlık Mod",
                            color: Color("SoftBlue")
                        ) {
                            Toggle("", isOn: $isDarkMode)
                                .tint(Color("Plum"))
                        }
                        
                        // Dil
                        TeacherSettingsRow(
                            icon: "globe",
                            title: "Dil",
                            color: Color("Plum")
                        ) {
                            Text("Türkçe")
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        // Yardım
                        TeacherSettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Yardım",
                            color: Color("FantasyPink")
                        ) {
                            NavigationLink {
                                HelpView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 15)
                    )
                    
                    // MARK: - Çıkış Yap Butonu
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Çıkış Yap")
                                .font(.custom("Outfit-Medium", size: 16))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .shadow(color: Color.red.opacity(0.1), radius: 10)
                        )
                    }
                }
                .padding(20)
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

// MARK: - Settings Row
struct TeacherSettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            // Başlık
            Text(title)
                .font(.custom("Outfit-Medium", size: 16))
                .foregroundColor(Color("NeutralBlack"))
            
            Spacer()
            
            // İçerik
            content()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    TeacherSettingsView()
}

