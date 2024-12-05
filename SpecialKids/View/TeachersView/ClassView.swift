import SwiftUI

struct ClassView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var studentsInClass: [Student] = []
    @State private var showAddStudentSheet = false
    @State private var selectedClass: SchoolClass?
    @State private var showClassManagement = false
    @State private var teacherClasses: [SchoolClass] = []
    @State private var selectedStudent: Student?
    @State private var showHomeworkSheet = false
    @State private var homeworkTitle: String = ""
    @State private var homeworkDescription: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(profileImage: Image("man")) {
                
            } onNotificationsButtonTapped: {
                
            }

            Button(action: {
                showClassManagement = true
            }) {
                Text(selectedClass?.name ?? "Sınıflarım")
                    .font(.custom(outfitMedium, size: 24))
                    .padding(.top)
            }
            .padding(.horizontal)

            if selectedClass != nil {
                // Add Student Button
                Button(action: {
                    showAddStudentSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Daha fazla öğrenci ekle")
                    }
                    .font(.custom(outfitLight, size: 16))
                    .foregroundColor(.gray)
                }
                
                // Students Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(studentsInClass) { student in
                            VStack {
                                Image("boy")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                
                                Text(student.name)
                                    .font(.custom(outfitMedium, size: 16))
                                
                                Text(student.id)
                                    .font(.custom(outfitLight, size: 12))
                                    .foregroundColor(.gray)
                            }
                            .onTapGesture {
                                selectedStudent = student
                                showHomeworkSheet = true
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Lütfen bir sınıf seçin veya oluşturun")
                    .font(.custom(outfitLight, size: 18))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .sheet(isPresented: $showAddStudentSheet) {
            if let selectedClass = selectedClass {
                AddStudentSheet(schoolClass: selectedClass) {
                    fetchStudentsForClass()
                }
                .presentationDetents([.fraction(0.5)])
            }
        }
        .sheet(isPresented: $showClassManagement) {
            ClassManagementView()
                .onDisappear {
                    fetchTeacherClasses()
                }
        }
        .sheet(isPresented: $showHomeworkSheet) {
            if let student = selectedStudent {
                HomeworkSheet(
                    student: student,
                    homeworkTitle: $homeworkTitle,
                    homeworkDescription: $homeworkDescription
                )
                .presentationDetents([.fraction(0.9)])
            }
        }
        .onAppear {
            fetchTeacherClasses()
        }
    }
    
    private func fetchStudentsForClass() {
        guard let classId = selectedClass?.id else { return }
        firebaseManager.fetchStudentsForClass(classId: classId) { students, error in
            if let students = students {
                studentsInClass = students
            }
        }
    }
    
    private func fetchTeacherClasses() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { classes, error in
            if let classes = classes {
                teacherClasses = classes
                if selectedClass == nil, let firstClass = classes.first {
                    selectedClass = firstClass
                    fetchStudentsForClass()
                }
            }
        }
    }
}
