import FirebaseFirestore
import FirebaseFirestore

struct CurriculumNote: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let content: String
    let date: Date
    let category: String
    let tags: [String]
    let attachments: [String]
    let teacherId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case date
        case category
        case tags
        case attachments
        case teacherId
    }
    
    init(
        id: String? = nil,
        title: String,
        content: String,
        date: Date = Date(),
        category: String = "Genel",
        tags: [String] = [],
        attachments: [String] = [],
        teacherId: String
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.category = category
        self.tags = tags
        self.attachments = attachments
        self.teacherId = teacherId
    }
}
