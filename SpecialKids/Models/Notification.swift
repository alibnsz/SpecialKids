import SwiftUI
import FirebaseFirestore

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    let parentId: String
    let title: String
    let message: String
    let date: Date
    var isRead: Bool
    let homeworkId: String?
    var homework: Homework?
    let type: NotificationType
    
    enum NotificationType: String, Codable {
        case homework = "homework"
        case message = "message"
        case alert = "alert"
    }
    
    static func createHomeworkNotification(
        parentId: String,
        homework: Homework
    ) -> Notification {
        return Notification(
            parentId: parentId,
            title: "Yeni Ödev",
            message: "'\(homework.title)' başlıklı yeni bir ödev gönderildi.",
            date: Date(),
            isRead: false,
            homeworkId: homework.id,
            homework: homework,
            type: .homework
        )
    }
} 
