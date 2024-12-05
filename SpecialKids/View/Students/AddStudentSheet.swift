//
//  AddStudentSheetView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct AddStudentSheet: View {
    let schoolClass: SchoolClass
    @State private var studentId = "" // Öğrenci ID'sini alacağız
    var onAddStudent: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Yeni Öğrenci Ekle")
                .font(.title)
                .padding()
            CustomTextField(placeholder: "Ogrenci ID", backgroundColor:.white, text: $studentId )
                .padding()
            CustomButton(title: "Ekle", backgroundColor: Color("MandyPink")) {
                guard !studentId.isEmpty else { return } // ID boş olmamalı
                
                // Öğrenci ID ile öğrenci verisini Firebase'den alıyoruz
                FirebaseManager.shared.getStudentById(id: studentId) { student in
                    guard let student = student else {
                        print("Öğrenci bulunamadı!")
                        return
                    }

                    // Öğrenciyi sınıfa ekliyoruz
                    FirebaseManager.shared.addStudentToClass(classId: schoolClass.id, studentId: student.id) { error in
                        if let error = error {
                            print("Hata: \(error.localizedDescription)")
                        } else {
                            onAddStudent()
                        }
                    }
                }
            }
            .padding()

        }
        .padding()
    }
}
