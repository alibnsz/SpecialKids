import SwiftUI

struct ClassView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var curriculumViewModel = CurriculumViewModel()
    @State private var showAddClassSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    VStack(spacing: 16) {
                        // Üst başlık
                        HStack {
                            Text("Öğrencilerinizi yönetin")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.secondary)
                            
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
                                
                                TextField("Sınıf ara...", text: $searchText)
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
                                showAddClassSheet = true
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
                    
                    // MARK: - Classes Grid
                    if firebaseManager.classes.isEmpty {
                        EmptyClassesView()
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredClasses) { schoolClass in
                                ClassCard(schoolClass: schoolClass)
                            }
                        }
                        .padding(.horizontal)
                        .animation(.spring(), value: firebaseManager.classes)
                    }
                }
                .padding(.top, 16)
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("Sınıflarım")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddClassSheet) {
                AddClassSheet()
                    .presentationDetents([.fraction(0.75)])
            }
            .onAppear {
                curriculumViewModel.fetchNotes()
            }
        }
    }
    
    private var filteredClasses: [SchoolClass] {
        if searchText.isEmpty {
            return firebaseManager.classes
        }
        return firebaseManager.classes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var upcomingEvents: [CurriculumNote] {
        let calendar = Calendar.current
        let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        
        return curriculumViewModel.notes.filter { note in
            note.date <= threeDaysFromNow && note.date >= Date()
        }.sorted { $0.date < $1.date }
    }
    
    private var upcomingEventsCount: Int {
        upcomingEvents.count
    }
}

// MARK: - Empty State View
struct EmptyClassesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.person.crop.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("Plum").opacity(0.3))
            
            Text("Henüz sınıf eklenmemiş")
                .font(.custom("Outfit-SemiBold", size: 20))
                .foregroundColor(Color("NeutralBlack"))
            
            Text("İlk sınıfınızı eklemek için + butonuna tıklayın")
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

// MARK: - Class Card
struct ClassCard: View {
    let schoolClass: SchoolClass
    
    var body: some View {
        NavigationLink(destination: ClassDetailView(schoolClass: schoolClass)) {
            VStack(spacing: 16) {
                // Sınıf ikonu
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("Plum").opacity(0.1),
                                    Color("Khaki").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("Plum"))
                }
                
                VStack(spacing: 4) {
                    Text(schoolClass.name)
                        .font(.custom("Outfit-SemiBold", size: 16))
                        .foregroundColor(Color("NeutralBlack"))
                    
                    Text("\(schoolClass.students.count) Öğrenci")
                        .font(.custom("Outfit-Regular", size: 14))
                        .foregroundColor(.secondary)
                }
                
                // İlerleme çubuğu
                ProgressView(value: Double(schoolClass.students.count), total: 30)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("Plum")))
                    .frame(height: 4)
            }
            .padding(16)
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
    }
}

#Preview {
    ClassView()
}
