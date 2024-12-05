import SwiftUI

struct TeacherView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var teacherClasses: [SchoolClass] = []
    @State private var showAddClassSheet = false
    @State private var newClassName = ""

    var body: some View {
        VStack {
            List(teacherClasses) { schoolClass in
                NavigationLink(destination: StudentListView(schoolClass: schoolClass)) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(schoolClass.name)
                                .font(.custom(outfitMedium, size: 20))
                                .foregroundColor(.primary)
                            
                            Text("\(schoolClass.students.count) Öğrenci")
                                .font(.custom(outfitLight, size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            CustomButton(title: "Sinif Ekle", backgroundColor: Color("MandyPink"), action: {
                showAddClassSheet = true
            })
            .padding()
            .sheet(isPresented: $showAddClassSheet) {
                VStack(spacing:0) {
                    Text("Yeni Sınıf Ekle")
                        .font(.custom(outfitLight, size: 20))
                    CustomTextField(placeholder: "Sinif Adi", backgroundColor: .white, text: $newClassName)
                        .padding()
                    CustomButton(title: "Sinifi Kaydet", backgroundColor: Color("MandyPink")) {
                        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
                        firebaseManager.createClassForTeacher(teacherId: teacherId, name: newClassName) { error in
                            if error == nil {
                                newClassName = ""
                                showAddClassSheet = false
                                fetchTeacherClasses()
                            }
                        }
                    }
                    .padding()
                }
                .presentationDetents([.medium]) // Farklı boyut seçenekleri
                .padding()
            }
        }
        .padding()
        .onAppear {
            fetchTeacherClasses()
        }
        .navigationTitle("Sınıflarım")
        
    }

    private func fetchTeacherClasses() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { classes, error in
            if let classes = classes {
                teacherClasses = classes
            }
        }
    }
}
#Preview {
    TeacherView()
}
