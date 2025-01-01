import SwiftUI
import FirebaseFirestore

struct CurriculumView: View {
    @StateObject private var viewModel = CurriculumViewModel()
    @State private var showAddNoteSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Üst kısım - Arama ve Ekleme
                    HStack {
                        // Arama alanı
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("BittersweetOrange"))
                            
                            TextField("Müfredat ara...", text: $searchText)
                                .font(.custom("Outfit-Regular", size: 16))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                        )
                        
                        // Ekleme butonu
                        Button {
                            showAddNoteSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("BittersweetOrange"))
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Müfredat notları listesi
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredNotes(searchText)) { note in
                            CurriculumNoteCard(note: note)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color("SoftBlue").opacity(0.05))
            .navigationTitle("Müfredat Notları")
            .sheet(isPresented: $showAddNoteSheet) {
                AddCurriculumNoteSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }
}

// MARK: - ViewModel
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
                        tags: data["tags"] as? [String] ?? []
                    )
                }
            }
    }
    
    func addNote(title: String, content: String, tags: [String]) {
        guard let teacherId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let noteData: [String: Any] = [
            "teacherId": teacherId,
            "title": title,
            "content": content,
            "date": Timestamp(date: Date()),
            "tags": tags
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
            note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Müfredat Not Kartı
struct CurriculumNoteCard: View {
    let note: CurriculumNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Başlık ve tarih
            HStack {
                Text(note.title)
                    .font(.custom("Outfit-SemiBold", size: 18))
                    .foregroundColor(Color("NeutralBlack"))
                
                Spacer()
                
                Text(formatDate(note.date))
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            
            // İçerik
            Text(note.content)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(Color("NeutralBlack").opacity(0.8))
                .lineLimit(3)
            
            // Etiketler
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(note.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.custom("Outfit-Medium", size: 12))
                            .foregroundColor(Color("BittersweetOrange"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("BittersweetOrange").opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Not Ekleme Sheet
struct AddCurriculumNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CurriculumViewModel
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık
                    CustomTextField(
                        placeholder: "Başlık",
                        text: $title
                    )
                    
                    // İçerik
                    TextEditor(text: $content)
                        .frame(height: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                    
                    // Etiket ekleme
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Etiketler")
                            .font(.custom("Outfit-Medium", size: 16))
                        
                        HStack {
                            CustomTextField(
                                placeholder: "Yeni etiket",
                                text: $newTag
                            )
                            
                            Button {
                                if !newTag.isEmpty {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color("BittersweetOrange"))
                                    .font(.system(size: 24))
                            }
                        }
                        
                        // Eklenen etiketler
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagView(tag: tag) {
                                    tags.removeAll { $0 == tag }
                                }
                            }
                        }
                    }
                    
                    // Kaydet butonu
                    CustomButtonView(
                        title: "Kaydet",
                        disabled: title.isEmpty || content.isEmpty,
                        type: .primary
                    ) {
                        saveNote()
                    }
                }
                .padding()
            }
            .navigationTitle("Yeni Not")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(Color("BittersweetOrange"))
                }
            }
        }
    }
    
    private func saveNote() {
        viewModel.addNote(
            title: title,
            content: content,
            tags: tags
        )
        dismiss()
    }
}

// MARK: - Tag View
struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.custom("Outfit-Regular", size: 14))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("BittersweetOrange").opacity(0.1))
        )
        .foregroundColor(Color("BittersweetOrange"))
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for size in sizes {
            if currentRowWidth + size.width > (proposal.width ?? .infinity) {
                // Yeni satıra geç
                width = max(width, currentRowWidth - spacing)
                height += currentRowHeight + spacing
                currentRowWidth = size.width + spacing
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        
        // Son satırı ekle
        width = max(width, currentRowWidth - spacing)
        height += currentRowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = CGPoint(x: bounds.minX, y: bounds.minY)
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > bounds.maxX {
                // Yeni satıra geç
                point.x = bounds.minX
                point.y += maxHeight + spacing
                maxHeight = 0
            }
            
            subview.place(at: point, proposal: .unspecified)
            point.x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}

// MARK: - Model
struct CurriculumNote: Identifiable {
    let id: String
    let title: String
    let content: String
    let date: Date
    let tags: [String]
} 