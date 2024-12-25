import SwiftUI

struct StudentNameView: View {
    let studentId: String
    @State private var studentName: String = ""

    var body: some View {
        HStack {
            if studentName.isEmpty {
                ProgressView()
            } else {
                Text(studentName)
            }
        }
        .onAppear {
            fetchStudentName()
        }
    }

    private func fetchStudentName() {
        FirebaseManager.shared.getStudentName(by: studentId) { name in
            if let name = name {
                studentName = name
            } else {
                studentName = "Bilinmeyen Öğrenci"
            }
        }
    }
}
