//
//  HomeworkSheet.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//
import SwiftUI

struct HomeworkSheet: View {
    let student: Student
    @Binding var homeworkTitle: String
    @Binding var homeworkDescription: String
    @State private var isHomeworkSent = false
    @State private var showAnimation = false

    var body: some View {
        VStack {
            if showAnimation {
                SwiftUIView()
                    .frame(width: 150, height: 150)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showAnimation = false // Animasyonu gizle
                        }
                    }
            }
            Text("Öğrenci Bilgileri")
                .font(.custom(outfitLight, size: 22))

            Text("Ad: \(student.name)")
            Text("ID: \(student.id)")
            Text("Yaş: \(student.age)")

            Divider()
                .padding(.vertical)

            // Ödev Verme Alanı
            Text("Ödev Ver")
                .font(.custom(outfitLight, size: 24))
            CustomTextField(placeholder: "Odev Basligi", backgroundColor: .white, text: $homeworkTitle)
                .padding()
            CustomTextField(placeholder: "Icerik", backgroundColor: .white, text: $homeworkDescription)
                .padding()
            CustomButton(title: "Gonder", backgroundColor: Color("NeutralBlack")) {
                sendHomework()
            }
            .padding()

            if isHomeworkSent {
                Text("Ödev başarıyla gönderildi!")
                    .foregroundColor(.green)
            }

          

        }
        .padding()
    }

    private func sendHomework() {
        guard !homeworkTitle.isEmpty, !homeworkDescription.isEmpty else {
            print("Ödev başlığı veya açıklaması boş!")
            return
        }

        let homeworkId = UUID().uuidString
        let dueDate = Date()

        let homework = Homework(id: homeworkId, title: homeworkTitle, description: homeworkDescription, dueDate: dueDate, studentId: student.id)

        FirebaseManager.shared.assignHomework(homework: homework) { error in
            if let error = error {
                print("Ödev gönderilirken hata: \(error.localizedDescription)")
            } else {
                isHomeworkSent = true
                homeworkTitle = ""
                homeworkDescription = ""
                showAnimation = true // Animasyonu başlat
            }
        }
    }
}
