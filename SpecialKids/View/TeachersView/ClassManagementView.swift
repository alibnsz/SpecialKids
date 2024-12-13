import SwiftUI

struct ClassManagementView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var classes: [SchoolClass] = []
    @State private var newClassName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedClass: SchoolClass?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sinif Secin")
                    .font(.custom(outfitMedium, size: 24))
                    .padding(.top, 20)
                
                // Existing classes dropdown
                Menu {
                    ForEach(classes) { schoolClass in
                        Button(action: {
                            selectedClass = schoolClass
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(schoolClass.name)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedClass?.name ?? "Sinif Adi")
                            .font(.custom(outfitLight, size: 16))
                            .foregroundColor(selectedClass == nil ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 325, height: 50)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                Text("veya")
                    .font(.custom(outfitLight, size: 16))
                    .foregroundColor(.gray)
                
                Text("Sinif olusturmak icin asagidaki alan sinif adini girin.")
                    .font(.custom(outfitLight, size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                CustomTextField(placeholder: "Sinif Adi", text: $newClassName)
                CustomButton(title: "Ekle", backgroundColor: Color("OilBlack")) {
                    addClass()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color.white)
        }
        .onAppear(perform: fetchClasses)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }

    private func fetchClasses() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { fetchedClasses, error in
            if let error = error {
                alertMessage = "Sınıflar yüklenirken hata oluştu: \(error.localizedDescription)"
                showAlert = true
            } else if let fetchedClasses = fetchedClasses {
                classes = fetchedClasses
            }
        }
    }

    private func addClass() {
        guard !newClassName.isEmpty else { return }
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }

        let newClass = SchoolClass(id: UUID().uuidString, name: newClassName, teacherId: teacherId)
        firebaseManager.addClass(newClass) { error in
            if let error = error {
                alertMessage = "Sınıf eklenirken hata oluştu: \(error.localizedDescription)"
                showAlert = true
            } else {
                classes.append(newClass)
                selectedClass = newClass
                newClassName = ""
                alertMessage = "Sınıf başarıyla eklendi."
                showAlert = true
            }
        }
    }

    private func deleteClass(at offsets: IndexSet) {
        offsets.forEach { index in
            let classToDelete = classes[index]
            firebaseManager.deleteClass(classId: classToDelete.id) { error in
                if let error = error {
                    alertMessage = "Sınıf silinirken hata oluştu: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    classes.remove(at: index)
                    if selectedClass! == classToDelete {
                        selectedClass = nil
                    }
                }
            }
        }
    }
}
