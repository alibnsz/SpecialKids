import SwiftUI

struct StudentCard: View {
    let student: Student
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Üst kısım - Profil ve İsim
                HStack(spacing: 12) {
                    // Profil resmi
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("BittersweetOrange").opacity(0.1),
                                        Color("FantasyPink").opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("BittersweetOrange"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(student.name)
                            .font(.custom("Outfit-SemiBold", size: 16))
                            .foregroundColor(Color("NeutralBlack"))
                        
                        Text("Öğrenci")
                            .font(.custom("Outfit-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Premium badge (eğer öğrenci premium ise)
                    if student.isPremium {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("FantasyPink"))
                    }
                }
                
                // Alt kısım - Detaylar
                HStack(spacing: 12) {
                    // Yaş
                    StudentInfoBadge(
                        icon: "calendar",
                        text: "\(student.age) yaş"
                    )
                    
                    // ID
                    StudentInfoBadge(
                        icon: "person.badge.key.fill",
                        text: student.studentId
                    )
                }
                
                // Ödev butonu
                HStack {
                    Spacer()
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14))
                    
                    Text("Ödev Ver")
                        .font(.custom("Outfit-Medium", size: 14))
                }
                .foregroundColor(Color("BittersweetOrange"))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("BittersweetOrange").opacity(0.1))
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Student Info Badge
struct StudentInfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            
            Text(text)
                .font(.custom("Outfit-Regular", size: 12))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("SoftBlue").opacity(0.1))
        )
    }
}

#Preview {
    StudentCard(
        student: Student(
            name: "Ahmet Yılmaz",
            age: 12,
            studentId: "ST123",
            isPremium: true
        )
    ) {}
    .padding()
} 