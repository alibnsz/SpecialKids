import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("allowPushNotifications") private var allowPushNotifications = true
    @AppStorage("allowHomeworkNotifications") private var allowHomeworkNotifications = true
    @AppStorage("allowMessageNotifications") private var allowMessageNotifications = true
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $allowPushNotifications) {
                    HStack(spacing: 16) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("BittersweetOrange"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Push Bildirimleri")
                                .font(.custom("Outfit-Medium", size: 16))
                            
                            Text("Tüm bildirimleri aç/kapat")
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color("BittersweetOrange"))
            }
            
            Section {
                Toggle(isOn: $allowHomeworkNotifications) {
                    HStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("FantasyPink"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ödev Bildirimleri")
                                .font(.custom("Outfit-Medium", size: 16))
                            
                            Text("Ödev teslim ve hatırlatmaları")
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color("BittersweetOrange"))
                
                Toggle(isOn: $allowMessageNotifications) {
                    HStack(spacing: 16) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("SoftBlue"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mesaj Bildirimleri")
                                .font(.custom("Outfit-Medium", size: 16))
                            
                            Text("Yeni mesaj bildirimleri")
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color("BittersweetOrange"))
            }
        }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("SoftBlue").opacity(0.05))
    }
} 