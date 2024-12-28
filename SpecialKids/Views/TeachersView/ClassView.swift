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
    @State private var showNotifications = false
    @State private var notifications: [Notification] = []
    
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Üst başlık - Hoşgeldin mesajı
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hoşgeldin,")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.secondary)
                            Text(teacherName)
                                .font(.custom("Outfit-SemiBold", size: 28))
                                .foregroundColor(Color("NeutralBlack"))
                        }
                        
                        Spacer()
                        
                        // Bildirim ve sınıf yönetimi ikonları
                        HStack(spacing: 12) {
                            Button(action: { showClassManagement = true }) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color("BittersweetOrange"))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 15)
                                    )
                            }
                            
                            NavigationLink {
                                NotificationsView(notifications: notifications)
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                NotificationButtonView(count: notifications.count)
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 16)
                    
                    if selectedClass == nil {
                        // Sınıf seçilmediğinde gösterilecek view
                        VStack(spacing: 24) {
                            // İllüstrasyon
                            Image(systemName: "rectangle.stack.person.crop.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color("BittersweetOrange"))
                                .padding(.bottom, 16)
                            
                            // Başlık ve açıklama
                            VStack(spacing: 8) {
                                Text("Henüz Bir Sınıfınız Yok")
                                    .font(.custom("Outfit-SemiBold", size: 24))
                                    .foregroundColor(Color("NeutralBlack"))
                                
                                Text("Öğrencilerinizi yönetmek için bir sınıf oluşturun veya seçin")
                                    .font(.custom("Outfit-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            
                            // Sınıf oluşturma butonu
                            CustomButtonView(
                                title: "Sınıf Seç",
                                type: .primary
                            ) {
                                showClassManagement = true
                            }
                            .frame(maxWidth: 200)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 15)
                        )
                        .padding(.horizontal, horizontalPadding)
                    } else {
                        // Sınıf seçildiğinde gösterilecek içerik
                        VStack(spacing: 24) {
                            // Sınıf bilgi kartı
                            ClassInfoCard(
                                className: selectedClass?.name ?? "",
                                studentCount: studentsInClass.count
                            )
                            .padding(.horizontal, horizontalPadding)
                            
                            // Öğrenci ekleme butonu
                            HStack {
                                Button(action: { showAddStudentSheet = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 18))
                                        Text("Öğrenci Ekle")
                                            .font(.custom("Outfit-Medium", size: 16))
                                    }
                                    .foregroundColor(Color("BittersweetOrange"))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("BittersweetOrange"), lineWidth: 1)
                                    )
                                }
                                .padding(.leading, horizontalPadding)
                                Spacer()
                            }
                            
                            // Öğrenci listesi
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ],
                                spacing: 20
                            ) {
                                ForEach(studentsInClass) { student in
                                    StudentCard(student: student) {
                                        selectedStudent = student
                                        showHomeworkSheet = true
                                    }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddStudentSheet) {
            if let selectedClass = selectedClass {
                AddStudentSheet(
                    schoolClass: selectedClass,
                    onStudentAdded: {
                        fetchStudentsForClass(classId: selectedClass.id)
                    }
                )
            }
        }
        .sheet(isPresented: $showClassManagement) {
            ClassManagementView(selectedClass: $selectedClass)
        }
        .sheet(isPresented: $showHomeworkSheet) {
            if let student = selectedStudent {
                HomeworkSheet(student: student)
            }
        }
        .onAppear {
            fetchInitialData()
            fetchNotifications()
        }
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
    
    private func fetchNotifications() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        
        Task {
            do {
                let fetchedNotifications = try await firebaseManager.fetchNotifications(for: teacherId)
                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications
                }
            } catch {
                print("Error fetching notifications: \(error)")
            }
        }
    }
}

// Yardımcı komponentler
struct ClassInfoCard: View {
    let className: String
    let studentCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(className)
                        .font(.custom("Outfit-SemiBold", size: 24))
                        .foregroundColor(Color("NeutralBlack"))
                    
                    Text("\(studentCount) Öğrenci")
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15)
        )
    }
}

struct StudentCard: View {
    let student: Student
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image("girl")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                
                VStack(spacing: 4) {
                    Text(student.name)
                        .font(.custom("Outfit-Medium", size: 16))
                        .foregroundColor(Color("NeutralBlack"))
                    
                    Text(student.studentId)
                        .font(.custom("Outfit-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
            )
        }
    }
}

#Preview {
    ClassView()
}
