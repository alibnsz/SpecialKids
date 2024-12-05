import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared

    var body: some View {
        NavigationView {
            VStack {
                if firebaseManager.isAuthenticated {
                    if firebaseManager.currentUserRole == "teacher" {
                        TeacherTabView()
                    } else if firebaseManager.currentUserRole == "parent" {
                        ParentTabView()
                    }
                } else {
                    LoginView()
                }
            }
            .onAppear {
                if firebaseManager.isAuthenticated {
                    firebaseManager.fetchClasses { _ in }
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
