import SwiftUI

struct ClassDetailView: View {
    let schoolClass: SchoolClass
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var showAddStudentSheet = false
    @State private var selectedStudent: Student?
    @State private var showHomeworkSheet = false
    @State private var students: [Student] = []
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return students
        }
        return students.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Search & Add Section
                HStack(spacing: 16) {
                    // Arama alanı
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("Plum"))
                            .font(.system(size: 20))
                        
                        TextField("Öğrenci ara...", text: $searchText)
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
                        showAddStudentSheet = true
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
                
                // MARK: - Students Section
                if students.isEmpty {
                    EmptyStudentsView()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredStudents) { student in
                            StudentCard(student: student) {
                                selectedStudent = student
                                showHomeworkSheet = true
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(), value: filteredStudents)
                }
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.05))
        .navigationTitle(schoolClass.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddStudentSheet) {
            AddStudentToClassSheet(classId: schoolClass.id)
                .presentationDetents([.fraction(0.75)])
        }
        .sheet(item: $selectedStudent) { student in
            HomeworkSheet(student: student)
        }
        .onAppear {
            fetchStudents()
        }
    }
    
    private func fetchStudents() {
        firebaseManager.fetchStudentsForClass(classId: schoolClass.id) { fetchedStudents, _ in
            if let fetchedStudents = fetchedStudents {
                students = fetchedStudents
            }
        }
    }
}

// MARK: - Empty State
struct EmptyStudentsView: View {
    var body: some View {
        VStack(spacing: 20) {
            // İkon
            ZStack {
                Circle()
                    .fill(Color("Plum").opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color("Plum"))
            }
            
            VStack(spacing: 8) {
                Text("Henüz öğrenci eklenmemiş")
                    .font(.custom("Outfit-SemiBold", size: 18))
                    .foregroundColor(Color("NeutralBlack"))
                
                Text("İlk öğrencinizi eklemek için + butonuna tıklayın")
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15)
        )
        .padding()
    }
} 
