import SwiftUI

struct StudentCard: View {
    let student: Student
    let action: () -> Void
    
    private var age: Int? {
        guard let birthDate = student.birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // MARK: - İsim ve Profil
                VStack(spacing: 4) {
                    // Profil Resmi
                    ZStack {
                        Circle()
                            .fill(Color("Plum").opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("Plum"))
                    }
                    
                    // İsim
                    Text(student.name)
                        .font(.custom("Outfit-SemiBold", size: 16))
                        .foregroundColor(Color("NeutralBlack"))
                    
                    Text("Bunsuz")
                        .font(.custom("Outfit-Regular", size: 14))
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Bilgiler
                HStack(spacing: 12) {
                    // Öğrenci ID
                    VStack(spacing: 2) {
                        Text("#")
                            .font(.custom("Outfit-Regular", size: 12))
                            .foregroundColor(.secondary)
                        Text(student.studentId)
                            .font(.custom("Outfit-Medium", size: 14))
                            .foregroundColor(Color("Plum"))
                    }
                    
                    // Yaş
                    if let age = age {
                        VStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("\(age) y")
                                .font(.custom("Outfit-Medium", size: 14))
                                .foregroundColor(Color("Plum"))
                        }
                    }
                }
                
                // MARK: - Ödev Butonu
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 14))
                    Text("Ödev Ver")
                        .font(.custom("Outfit-Medium", size: 14))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color("Plum"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color("Plum").opacity(0.1))
                .cornerRadius(8)
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Plum").opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    StudentCard(
        student: Student(
            name: "Emin",
            age: 12,
            studentId: "34257",
            birthDate: Calendar.current.date(byAdding: .year, value: -12, to: Date()),
            isPremium: true
        )
    ) {}
    .padding()
} 
