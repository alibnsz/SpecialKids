import SwiftUI
import FirebaseFirestore

class CurriculumViewModel: ObservableObject {
    @Published var notes: [CurriculumNote] = []
    private let db = Firestore.firestore()
    
    func fetchNotes() {
        guard let teacherId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        db.collection("curriculum")
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching notes: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self?.notes = documents.compactMap { document -> CurriculumNote? in
                    let data = document.data()
                    return CurriculumNote(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        content: data["content"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        category: data["category"] as? String ?? "Genel",
                        tags: data["tags"] as? [String] ?? [],
                        attachments: []  // Dosya yükleme işlemi için storage entegrasyonu gerekiyor
                    )
                }
            }
    }
    
    func addNote(title: String, content: String, category: String, attachments: [AttachmentItem], tags: [String]) {
        guard let teacherId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let noteData: [String: Any] = [
            "teacherId": teacherId,
            "title": title,
            "content": content,
            "date": Timestamp(date: Date()),
            "category": category,
            "tags": tags
            // Dosya yükleme işlemi için storage entegrasyonu gerekiyor
        ]
        
        db.collection("curriculum").addDocument(data: noteData) { error in
            if let error = error {
                print("Error adding note: \(error.localizedDescription)")
            }
        }
    }
    
    func filteredNotes(_ searchText: String) -> [CurriculumNote] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            note.category.localizedCaseInsensitiveContains(searchText) ||
            note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
} 