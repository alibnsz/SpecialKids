struct EducationContent: Codable {
    let categories: [EducationCategory]
}

struct EducationCategory: Codable, Identifiable {
    let id: String
    let title: String
    let image: String
    let color: String
    let articles: [EducationArticle]
}

struct EducationArticle: Codable, Identifiable {
    let id: String
    let title: String
    let image: String
    let content: String
    let tips: [String]?
} 