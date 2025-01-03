import SwiftUI

struct CurriculumView: View {
    @StateObject private var viewModel = CurriculumViewModel()
    @State private var showAddNoteSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    VStack(spacing: 16) {
                        // Üst başlık
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Müfredat Notları")
                                    .font(.custom("Outfit-Bold", size: 28))
                                    .foregroundColor(Color("NeutralBlack"))
                                
                                Text("Öğrencileriniz için notlar ve planlar")
                                    .font(.custom("Outfit-Regular", size: 16))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Arama ve Ekleme Bölümü
                        HStack(spacing: 16) {
                            // Arama alanı
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color("Plum"))
                                    .font(.system(size: 20))
                                
                                TextField("Müfredat ara...", text: $searchText)
                                    .font(.custom("Outfit-Regular", size: 16))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                            )
                            
                            // Ekleme butonu
                            Button {
                                showAddNoteSheet = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 46, height: 46)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color("DarkPurple"),
                                                Color("Plum")
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(
                                        color: Color("Plum").opacity(0.3),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Content Section
                    if viewModel.notes.isEmpty {
                        CurriculumEmptyStateView()
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.filteredNotes(searchText)) { note in
                                CurriculumNoteCard(note: note)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .animation(.spring(), value: viewModel.notes.map { $0.id })
                    }
                }
                .padding(.top, 16)
            }
            .background(Color.gray.opacity(0.05))
            .sheet(isPresented: $showAddNoteSheet) {
                AddCurriculumNoteSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchNotes()
            }
        }
    }
}

// MARK: - Empty State View
struct CurriculumEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("Plum").opacity(0.3))
            
            Text("Henüz not eklenmemiş")
                .font(.custom("Outfit-SemiBold", size: 20))
                .foregroundColor(Color("NeutralBlack"))
            
            Text("İlk müfredat notunuzu eklemek için + butonuna tıklayın")
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15)
        )
        .padding()
    }
}

// MARK: - Not Kartı Tasarımı
struct CurriculumNoteCard: View {
    let note: CurriculumNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Başlık ve tarih
            HStack {
                Text(note.title)
                    .font(.custom("Outfit-SemiBold", size: 18))
                    .foregroundColor(Color("NeutralBlack"))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text(formatDate(note.date))
                        .font(.custom("Outfit-Regular", size: 14))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            // İçerik
            Text(note.content)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(Color("NeutralBlack").opacity(0.8))
                .lineLimit(3)
                .padding(.vertical, 8)
            
            // Etiketler
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(note.tags, id: \.self) { tag in
                        TagView(tag: tag) {}
                    }
                }
            }
            
            // Alt bilgi çizgisi
            HStack {
                Image(systemName: "text.justify")
                    .foregroundColor(.secondary)
                Text("\(note.content.split(separator: " ").count) kelime")
                    .font(.custom("Outfit-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(
                    color: Color("Plum").opacity(0.05),
                    radius: 15,
                    x: 0,
                    y: 5
                )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
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
                .fill(Color("Plum").opacity(0.1))
        )
        .foregroundColor(Color("Plum"))
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
