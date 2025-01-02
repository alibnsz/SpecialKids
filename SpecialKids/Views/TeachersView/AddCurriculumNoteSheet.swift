import SwiftUI
import UniformTypeIdentifiers

struct AddCurriculumNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CurriculumViewModel
    @State private var noteData = NoteFormData()
    @State private var showDocumentPicker = false
    @State private var showPreview = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Başlık ve Kategori
                    HeaderSection(noteData: $noteData)
                    
                    // MARK: - İçerik
                    ContentSection(content: $noteData.content)
                    
                    // MARK: - Dosya Ekleme
                    AttachmentSection(
                        attachments: $noteData.attachments,
                        showDocumentPicker: $showDocumentPicker
                    )
                    
                    // MARK: - Etiketler
                    TagSection(
                        tags: $noteData.tags,
                        newTag: $noteData.newTag
                    )
                    
                    // MARK: - Önizleme ve Kaydet
                    ActionButtons(
                        noteData: noteData,
                        showPreview: $showPreview,
                        onSave: saveNote
                    )
                }
                .padding(20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Yeni Not")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("Plum"))
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(attachments: $noteData.attachments)
            }
            .sheet(isPresented: $showPreview) {
                NotePreviewView(noteData: noteData)
            }
        }
    }
    
    private func saveNote() {
        viewModel.addNote(
            title: noteData.title,
            content: noteData.content,
            category: noteData.selectedCategory,
            attachments: noteData.attachments,
            tags: noteData.tags
        )
        dismiss()
    }
}

// MARK: - Form Data Model
struct NoteFormData {
    var title = ""
    var content = ""
    var tags: [String] = []
    var newTag = ""
    var selectedCategory = "Genel"
    var attachments: [AttachmentItem] = []
}

// MARK: - Header Section
struct HeaderSection: View {
    @Binding var noteData: NoteFormData
    let categories = ["Genel", "Matematik", "Fen", "Türkçe", "Sosyal", "İngilizce", "Diğer"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Başlık
            VStack(alignment: .leading, spacing: 8) {
                Text("Başlık")
                    .font(.custom("Outfit-Medium", size: 14))
                    .foregroundColor(.secondary)
                
                CustomTextField(
                    placeholder: "Not başlığını girin",
                    text: $noteData.title
                )
            }
            
            // Kategori Seçimi
            CategoryPicker(
                selectedCategory: $noteData.selectedCategory,
                categories: categories
            )
        }
    }
}

// MARK: - Content Section
struct ContentSection: View {
    @Binding var content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İçerik")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            TextEditor(text: $content)
                .frame(minHeight: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
        }
    }
}

// MARK: - Attachment Section
struct AttachmentSection: View {
    @Binding var attachments: [AttachmentItem]
    @Binding var showDocumentPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ekler")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            if !attachments.isEmpty {
                VStack(spacing: 8) {
                    ForEach(attachments) { attachment in
                        AttachmentRow(attachment: attachment) {
                            if let index = attachments.firstIndex(of: attachment) {
                                attachments.remove(at: index)
                            }
                        }
                    }
                }
            }
            
            AddAttachmentButton(showDocumentPicker: $showDocumentPicker)
        }
    }
}

// MARK: - Tag Section
struct TagSection: View {
    @Binding var tags: [String]
    @Binding var newTag: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Etiketler")
                .font(.custom("Outfit-Medium", size: 14))
                .foregroundColor(.secondary)
            
            TagInput(newTag: $newTag, tags: $tags)
            
            TagList(tags: $tags)
        }
    }
}

// MARK: - Action Buttons
struct ActionButtons: View {
    let noteData: NoteFormData
    @Binding var showPreview: Bool
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            PreviewButton(showPreview: $showPreview)
            SaveButton(isDisabled: noteData.title.isEmpty || noteData.content.isEmpty, onSave: onSave)
        }
    }
}

// MARK: - Attachment Item
struct AttachmentItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
    let type: AttachmentType
    
    enum AttachmentType {
        case pdf
        case image
        case document
        
        var icon: String {
            switch self {
            case .pdf: return "doc.pdf"
            case .image: return "photo"
            case .document: return "doc.text"
            }
        }
    }
}

// MARK: - Attachment Row
struct AttachmentRow: View {
    let attachment: AttachmentItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: attachment.type.icon)
                .font(.system(size: 20))
                .foregroundColor(Color("Plum"))
            
            Text(attachment.name)
                .font(.custom("Outfit-Regular", size: 14))
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var attachments: [AttachmentItem]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            .pdf,
            .image,
            .text
        ])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for url in urls {
                let type: AttachmentItem.AttachmentType
                switch url.pathExtension.lowercased() {
                case "pdf": type = .pdf
                case "jpg", "jpeg", "png": type = .image
                default: type = .document
                }
                
                let attachment = AttachmentItem(
                    name: url.lastPathComponent,
                    url: url,
                    type: type
                )
                parent.attachments.append(attachment)
            }
        }
    }
}

// MARK: - Note Preview
struct NotePreviewView: View {
    let noteData: NoteFormData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Başlık ve Kategori
                    VStack(alignment: .leading, spacing: 8) {
                        Text(noteData.title)
                            .font(.custom("Outfit-Bold", size: 24))
                            .foregroundColor(Color("NeutralBlack"))
                        
                        Text(noteData.selectedCategory)
                            .font(.custom("Outfit-Medium", size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color("Plum").opacity(0.1))
                            )
                    }
                    
                    // İçerik
                    Text(noteData.content)
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(Color("NeutralBlack"))
                    
                    // Ekler
                    if !noteData.attachments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ekler")
                                .font(.custom("Outfit-SemiBold", size: 16))
                            
                            ForEach(noteData.attachments) { attachment in
                                AttachmentRow(attachment: attachment) {}
                            }
                        }
                    }
                    
                    // Etiketler
                    if !noteData.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Etiketler")
                                .font(.custom("Outfit-SemiBold", size: 16))
                            
                            FlowLayout(spacing: 8) {
                                ForEach(noteData.tags, id: \.self) { tag in
                                    TagView(tag: tag) {}
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Önizleme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("Plum"))
                }
            }
        }
    }
} 
