import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [Notification]
    
    init(notifications: [Notification]) {
        _notifications = State(initialValue: notifications)
    }
    
    var body: some View {
        Group {
            if notifications.isEmpty {
                EmptyNotificationsView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(notifications) { notification in
                            if let homework = notification.homework {
                                NavigationLink(destination: HomeworkDetailView(homework: homework)) {
                                    NotificationCard(notification: notification)
                                }
                            } else {
                                NotificationCard(notification: notification)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Bildirimler")
        .onAppear {
            print("Notifications count: \(notifications.count)")
            notifications.forEach { notification in
                print("Notification: \(notification.title), Has Homework: \(notification.homework != nil)")
            }
        }
    }
}

struct NotificationCard: View {
    let notification: Notification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(notification.title)
                .font(.custom("Outfit-SemiBold", size: 16))
                .foregroundColor(Color("NeutralBlack"))
            
            Text(notification.message)
                .font(.custom("Outfit-Regular", size: 14))
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(formatDate(notification.date))
                    .font(.custom("Outfit-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Bildirim Bulunmuyor")
                .font(.custom("Outfit-Medium", size: 18))
                .foregroundColor(.secondary)
            
            Text("Yeni bildirimler geldiğinde burada görünecek")
                .font(.custom("Outfit-Regular", size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
    }
} 
