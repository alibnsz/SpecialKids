//
//  HomeworkListView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 23.11.2024.
//

import SwiftUI

struct HomeworkListView: View {
    let child: Student
    @State private var assignments: [Assignment] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Ödevler Yükleniyor...")
            } else if assignments.isEmpty {
                Text("Henüz ödev yok.")
                    .foregroundColor(.gray)
            } else {
                List(assignments) { assignment in
                    VStack(alignment: .leading) {
                        Text(assignment.title)
                            .font(.headline)
                        Text(assignment.description)
                            .font(.subheadline)
                        Text("Son Teslim Tarihi: \(assignment.dueDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("\(child.name)'in Ödevleri")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAssignments()
        }
    }
    
    private func fetchAssignments() {
        FirebaseManager.shared.fetchAssignmentsForStudent(studentId: child.id) { assignments, error in
            if let error = error {
                print("Ödevler yüklenirken hata: \(error.localizedDescription)")
            } else if let assignments = assignments {
                self.assignments = assignments
            }
            isLoading = false
        }
    }
}

