//
//  StudentListView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

struct StudentListView: View {
    let schoolClass: SchoolClass
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var studentsInClass: [Student] = []
    @State private var selectedStudent: Student? = nil
    @State private var showHomeworkSheet = false
    @State private var showAddStudentSheet = false
    
    // Ödev Verme için
    @State private var homeworkTitle = ""
    @State private var homeworkDescription = ""
    
    var body: some View {
        VStack {
            List(studentsInClass) { student in
                Button(action: {
                    selectedStudent = student
                    showHomeworkSheet = true
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(student.name)
                                .font(.custom(outfitMedium, size: 20))
                                .foregroundColor(.primary)
                            Text("ID: \(student.id)")
                                .font(.custom(outfitLight, size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                fetchStudentsForClass()
            }
            
            CustomButton(title: "Ogrenci Ekle", backgroundColor: Color("MandyPink")) {
                showAddStudentSheet = true
            }
            .padding()
            .sheet(isPresented: $showAddStudentSheet) {
                AddStudentSheet(schoolClass: schoolClass) {
                    fetchStudentsForClass() // Listeyi güncellemek için tekrar çek
                    showAddStudentSheet = false
                }
                .presentationDetents([.medium]) // Farklı boyut seçenekleri
            }
        }
        .padding()
        .navigationTitle("\(schoolClass.name) Sınıfı")
        .sheet(isPresented: $showHomeworkSheet) {
            if let student = selectedStudent {
                HomeworkSheet(student: student,
                              homeworkTitle: $homeworkTitle,
                              homeworkDescription: $homeworkDescription)
            }
        }
    }
    
    private func fetchStudentsForClass() {
        firebaseManager.fetchStudentsForClass(classId: schoolClass.id) { students, error in
            if let students = students {
                studentsInClass = students
            }
        }
    }
}
