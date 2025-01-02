import SwiftUI

struct ArticleDetailView: View {
    let article: EducationArticle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Ana Görsel
                Image(article.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()
                
                // İçerik Bölümü
                VStack(alignment: .leading, spacing: 40) {
                    // Başlık ve Ana İçerik
                    TitleSection(title: article.title, content: article.content)
                    
                    // İkinci Görsel
                    AnimatedImageView(image: article.image)
                    
                    // Belirtiler Bölümü
                    SymptomsSection()
                    
                    // Üçüncü Görsel
                    AnimatedImageView(image: article.image)
                    
                    // Öneriler Bölümü
                    if let tips = article.tips {
                        TipsSection(tips: tips)
                    }
                }
                .padding(.horizontal, 32)
            }
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AnimatedImageView: View {
    let image: String
    @State private var isVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let screenHeight = UIScreen.main.bounds.height
            let shouldShow = minY < screenHeight && minY > -geometry.size.height
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .opacity(shouldShow ? 1 : 0)
                .scaleEffect(shouldShow ? 1 : 0.95)
                .animation(.easeInOut(duration: 0.3), value: shouldShow)
                #if compiler(>=5.9)
                .onChange(of: minY) { oldValue, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = newValue > 0
                    }
                }
                #else
                .onChange(of: minY) { value in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = value > 0
                    }
                }
                #endif
        }
        .frame(height: 200)
    }
}

// MARK: - Content Section

// MARK: - Title Section
private struct TitleSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Outfit-Bold", size: 32))
                .foregroundColor(Color("NeutralBlack"))
            
            Text(content)
                .font(.custom("Outfit-Regular", size: 17))
                .foregroundColor(.secondary)
                .lineSpacing(8)
        }
    }
}

// MARK: - Symptoms Section
private struct SymptomsSection: View {
    private let symptoms = [
        "Dikkat süresinin kısa olması",
        "Hareketlilik ve dürtüsellik",
        "Organizasyon zorluğu",
        "Unutkanlık",
        "Sosyal ilişkilerde zorluk"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Belirtiler")
                .font(.custom("Outfit-Bold", size: 28))
                .foregroundColor(Color("NeutralBlack"))
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(symptoms, id: \.self) { symptom in
                    BulletPoint(text: symptom)
                }
            }
        }
    }
}

// MARK: - Tips Section
private struct TipsSection: View {
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Öneriler")
                .font(.custom("Outfit-Bold", size: 28))
                .foregroundColor(Color("NeutralBlack"))
            
            VStack(spacing: 16) {
                ForEach(tips, id: \.self) { tip in
                    TipRow(tip: tip)
                }
            }
        }
    }
}

// MARK: - Bullet Point
private struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color("Plum"))
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            
            Text(text)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Tip Row
private struct TipRow: View {
    let tip: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Color("Plum"))
                .font(.system(size: 24))
            
            Text(tip)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
} 
