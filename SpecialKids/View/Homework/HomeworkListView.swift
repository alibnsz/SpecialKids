//
//  HomeworkListView.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 23.11.2024.
//

import SwiftUI
import FirebaseFirestore

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
                    HomeworkRow(homework: assignment)
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
            isLoading = false
            if let error = error {
                print("Ödevler yüklenirken hata: \(error.localizedDescription)")
            } else if let assignments = assignments {
                self.assignments = assignments
            }
        }
    }
}

struct HomeworkRow: View {
    let homework: Homework
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(homework.title)
                .font(.headline)
            Text(homework.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("Teslim Tarihi: \(formatDate(homework.dueDate))")
                    .font(.caption)
                Spacer()
                StatusBadge(status: homework.status)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: HomeworkStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .completed: return .green
        case .late: return .red
        }
    }
}

