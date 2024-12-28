import SwiftUI

struct EducationView: View {
    @State private var categories: [EducationCategory] = []
    @State private var selectedCategory: EducationCategory?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                Text("Eğitim Rehberi")
                    .font(.custom("Outfit-Bold", size: 28))
                    .foregroundColor(Color("NeutralBlack"))
                    .padding(.horizontal, 24)
                
                // Kategoriler
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory?.id == category.id
                            ) {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Makaleler
                if let category = selectedCategory {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(category.articles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                ArticleRow(article: article)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.gray.opacity(0.05))
        .onAppear {
            loadEducationContent()
        }
    }
    
    private func loadEducationContent() {
        if let url = Bundle.main.url(forResource: "education_content", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let content = try decoder.decode(EducationContent.self, from: data)
                categories = content.categories
                selectedCategory = content.categories.first
            } catch {
                print("Error loading education content: \(error)")
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: EducationCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.title)
                .font(.custom("Outfit-Medium", size: 15))
                .foregroundColor(isSelected ? .white : Color("NeutralBlack"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color("BittersweetOrange") : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("BittersweetOrange").opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Article Row
struct ArticleRow: View {
    let article: EducationArticle
    
    var body: some View {
        HStack(spacing: 16) {
            // Makale Görseli
            Image(article.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Makale Başlığı ve Kısa Açıklama
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.custom("Outfit-SemiBold", size: 16))
                    .foregroundColor(Color("NeutralBlack"))
                
                Text(article.content.components(separatedBy: "\n").first ?? "")
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
} 