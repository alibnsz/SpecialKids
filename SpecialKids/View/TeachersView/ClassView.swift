import SwiftUI

struct ClassView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var showAddStudentSheet = false
    @State private var selectedClass: SchoolClass?
    @State private var showClassManagement = false
    @State private var studentsInClass: [Student] = []
    @State private var teacherName: String = ""
    @State private var selectedStudent: Student?
    @State private var showHomeworkSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
            
                if selectedClass != nil {
                    HeaderView(profileImage: Image("man"),name: "Hoşgeldin, \(teacherName)") {
                        
                    } onNotificationsButtonTapped: {
                        
                    }

                    // Üst Başlık
                    VStack(alignment: .leading, spacing: 4) {
                        
                        HStack {
                            Button(action: { showAddStudentSheet = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color("OilBlack"))
                                    Text("Daha fazla öğrenci ekle")
                                        .font(.custom("Outfit-Regular", size: 16))
                                        .foregroundColor(Color("OilBlack"))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { showClassManagement = true }) {
                                Text("Sınıflarım")
                                    .font(.custom("Outfit-Medium", size: 16))
                                    .foregroundColor(Color("OilBlack"))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Öğrenci Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 24) {
                            ForEach(studentsInClass) { student in
                                NavigationLink(destination: HomeworkSheet(student: student)) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(Color("OilBlack"))
                                            .background(Circle().fill(Color.white))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                                        
                                        Text(student.name)
                                            .font(.custom("Outfit-Medium", size: 16))
                                            .foregroundColor(Color("OilBlack"))
                                        
                                        Text(student.studentId)
                                            .font(.custom("Outfit-Regular", size: 12))
                                            .foregroundColor(Color("OilBlack"))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Lütfen bir sınıf seçin")
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(Color("OilBlack"))
                }
            }
            .sheet(isPresented: $showAddStudentSheet) {
                if let selectedClass = selectedClass {
                    AddStudentSheet(
                        schoolClass: selectedClass,
                        onStudentAdded: {
                            fetchStudentsForClass(classId: selectedClass.id)
                        }
                    )
                    .presentationDetents([.fraction(0.40)])
                }
            }
            .sheet(isPresented: $showClassManagement) {
                ClassManagementView(selectedClass: $selectedClass)
                    .presentationDetents([.fraction(0.65)])
                    .onDisappear {
                        if let selectedClass = selectedClass {
                            fetchStudentsForClass(classId: selectedClass.id)
                        }
                    }
            }
            .onAppear {
                fetchTeacherClasses()
                fetchTeacherName()
            }
        }
    }
    
    private func fetchTeacherName() {
        firebaseManager.fetchTeacherName { name in
            DispatchQueue.main.async {
                self.teacherName = name
            }
        }
    }
    
    private func fetchStudentsForClass(classId: String) {
        print("Öğrenciler getiriliyor...")
        firebaseManager.fetchStudentsForClass(classId: classId) { students, error in
            if let error = error {
                print("Öğrenci getirme hatası: \(error.localizedDescription)")
                return
            }
            
            if let students = students {
                print("Bulunan öğrenci sayısı: \(students.count)")
                DispatchQueue.main.async {
                    self.studentsInClass = students
                }
            }
        }
    }
    
    private func fetchTeacherClasses() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { classes, error in
            if let classes = classes {
                if selectedClass == nil, let firstClass = classes.first {
                    selectedClass = firstClass
                    fetchStudentsForClass(classId: firstClass.id)
                }
            }
        }
    }
}
#Preview {
    ClassView()
}
