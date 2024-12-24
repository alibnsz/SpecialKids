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
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else if selectedClass == nil {
                    VStack(spacing: 16) {
                        Text("Lütfen bir sınıf seçin")
                            .font(.custom("Outfit-Regular", size: 16))
                            .foregroundColor(Color("OilBlack"))
                        
                        Button(action: { showClassManagement = true }) {
                            Text("Sınıf Seç")
                                .font(.custom("Outfit-Medium", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color("BittersweetOrange"))
                                .cornerRadius(25)
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            HeaderView(profileImage: Image("man"), name: "Hoşgeldin, \(teacherName)") {
                                
                            } onNotificationsButtonTapped: {
                                
                            }
                            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                            
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
                            .padding(.top, 16)
                            
                            // Öğrenci Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 24) {
                                ForEach(studentsInClass) { student in
                                    NavigationLink(destination: HomeworkSheet(student: student)) {
                                        VStack(spacing: 8) {
                                            Image("girl")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                                .background(
                                                    Circle()
                                                        .fill(Color.white)
                                                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                                                )
                                            
                                            Text(student.name)
                                                .font(.custom("Outfit-Medium", size: 16))
                                                .foregroundColor(Color("OilBlack"))
                                            
                                            Text(student.studentId)
                                                .font(.custom("Outfit-Regular", size: 12))
                                                .foregroundColor(Color("OilBlack"))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)
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
                fetchInitialData()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func fetchInitialData() {
        isLoading = true
        
        guard let teacherId = firebaseManager.auth.currentUser?.uid else {
            isLoading = false
            return
        }
        
        // Öğretmen adını al
        firebaseManager.fetchTeacherName { name in
            self.teacherName = name
        }
        
        // Sınıfları al
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { classes, error in
            if let classes = classes, let firstClass = classes.first {
                selectedClass = firstClass
                fetchStudentsForClass(classId: firstClass.id)
            }
            isLoading = false
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
}
#Preview {
    ClassView()
}
