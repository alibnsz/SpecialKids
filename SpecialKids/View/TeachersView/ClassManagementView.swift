//
//  ClassManagementView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 5.12.2024.
//


import SwiftUI

struct ClassManagementView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var classes: [SchoolClass] = []
    @State private var newClassName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Yeni Sınıf Ekle")) {
                    HStack {
                        TextField("Sınıf Adı", text: $newClassName)
                        Button(action: addClass) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }

                Section(header: Text("Mevcut Sınıflar")) {
                    ForEach(classes) { schoolClass in
                        Text(schoolClass.name)
                    }
                    .onDelete(perform: deleteClass)
                }
            }
            .navigationBarTitle("Sınıf Yönetimi", displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
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
                }
            }
        }
    }
}
