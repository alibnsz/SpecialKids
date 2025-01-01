import FirebaseFirestore

struct CurriculumNote: Identifiable, Equatable {
    let id: String
    let title: String
    let content: String
    let date: Date
    let category: String
    let tags: [String]
    let attachments: [AttachmentItem]
    
    init(id: String, title: String, content: String, date: Date, category: String = "Genel", tags: [String] = [], attachments: [AttachmentItem] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.category = category
        self.tags = tags
        self.attachments = attachments
    }
    
    static func == (lhs: CurriculumNote, rhs: CurriculumNote) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.category == rhs.category &&
        lhs.tags == rhs.tags &&
        lhs.attachments == rhs.attachments
    }
}