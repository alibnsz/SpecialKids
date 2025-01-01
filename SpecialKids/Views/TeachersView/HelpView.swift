import SwiftUI

struct HelpView: View {
    let helpItems: [(title: String, icon: String, description: String)] = [
        (
            title: "Öğrenci Ekleme",
            icon: "person.badge.plus",
            description: "Sınıfınıza öğrenci eklemek için öğrencinin ID'sini kullanın."
        ),
        (
            title: "Ödev Verme",
            icon: "square.and.pencil",
            description: "Öğrenci kartına tıklayarak ödev verebilirsiniz."
        ),
        (
            title: "Müfredat Notları",
            icon: "doc.text",
            description: "Müfredat bölümünden notlarınızı yönetebilirsiniz."
        ),
        (
            title: "İletişim",
            icon: "envelope",
            description: "Destek için: destek@specialkids.com"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(helpItems, id: \.title) { item in
                    HelpCard(
                        title: item.title,
                        icon: item.icon,
                        description: item.description
                    )
                }
            }
            .padding(20)
        }
        .background(Color("SoftBlue").opacity(0.05))
        .navigationTitle("Yardım")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct HelpCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // İkon
                ZStack {
                    Circle()
                        .fill(Color("BittersweetOrange").opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color("BittersweetOrange"))
                }
                
                Text(title)
                    .font(.custom("Outfit-SemiBold", size: 18))
                    .foregroundColor(Color("NeutralBlack"))
            }
            
            Text(description)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
} 