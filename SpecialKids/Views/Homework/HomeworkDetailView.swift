import SwiftUI
import FirebaseFirestore

struct HomeworkDetailView: View {
    let homework: Homework?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Ödev Başlığı
                Text(homework?.title ?? "")
                    .font(.custom("Outfit-Bold", size: 24))
                    .foregroundColor(Color("NeutralBlack"))
                
                // Ödev Detayları
                VStack(alignment: .leading, spacing: 16) {
                    // Ödev Açıklaması
                    Text(homework?.description ?? "")
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                    
                    // Ödev Bilgileri
                    InfoRow(title: "Son Teslim Tarihi", value: formatDate(homework?.dueDate))
                    if let teacherId = homework?.teacherId {
                        InfoRow(title: "Öğretmen ID", value: teacherId)
                    }
                    InfoRow(title: "Durum", value: homework?.status.rawValue ?? "pending", isStatus: true)
                    
                    if let remainingTime = homework?.remainingTime {
                        InfoRow(title: "Kalan Süre", value: remainingTime)
                    }
                }
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                
                // Sınıf Bilgisi
                if let className = homework?.className {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sınıf")
                            .font(.custom("Outfit-SemiBold", size: 18))
                        
                        Text(className)
                            .font(.custom("Outfit-Regular", size: 15))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var isStatus: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Outfit-Regular", size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if isStatus {
                Text(value.capitalized)
                    .font(.custom("Outfit-Medium", size: 15))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(statusColor.opacity(0.1))
                    )
            } else {
                Text(value)
                    .font(.custom("Outfit-Medium", size: 15))
                    .foregroundColor(Color("NeutralBlack"))
            }
        }
    }
    
    private var statusColor: Color {
        switch value.lowercased() {
        case "completed":
            return .green
        case "late":
            return .red
        default:
            return .orange
        }
    }
} 