import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ParentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var children: [Student] = []
    @State private var showAddChildSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if children.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(children) { child in
                            ChildCardView(child: child)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .navigationTitle("Çocuklarım")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddChildSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("BittersweetOrange"))
                    }
                }
            }
            .fullScreenCover(isPresented: $showAddChildSheet) {
                AddChildView()
            }
            .onAppear {
                fetchChildren()
            }
        }
    }
    
    private func fetchChildren() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("children")
            .whereField("parentId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching children: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    self.children = documents.compactMap { document -> Student? in
                        let data = document.data()
                        return Student(
                            id: document.documentID,
                            name: data["name"] as? String ?? "",
                            age: data["age"] as? Int ?? 0,
                            studentId: data["studentId"] as? String ?? "",
                            birthDate: (data["birthDate"] as? Timestamp)?.dateValue()
                        )
                    }
                }
            }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @State private var showAddChildSheet = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image("empty-state-illustration") // Özel bir illüstrasyon ekleyebilirsiniz
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.top, 40)
            
            VStack(spacing: 12) {
                Text("Henüz çocuk eklenmedi")
                    .font(.custom("Outfit-SemiBold", size: 20))
                    .foregroundColor(.primary)
                
                Text("Çocuğunuzu ekleyerek özel eğitim yolculuğuna başlayın")
                    .font(.custom("Outfit-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            CustomButtonView(
                title: "Çocuk Ekle",
                type: .primary
            ) {
                showAddChildSheet = true
            }
            .frame(maxWidth: 200)
        }
        .padding()
        .fullScreenCover(isPresented: $showAddChildSheet) {
            AddChildView()
        }
    }
}

// MARK: - Child Card View
struct ChildCardView: View {
    let child: Student
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                Circle()
                    .fill(Color("BittersweetOrange").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(child.name.prefix(1).uppercased())
                            .font(.custom("Outfit-SemiBold", size: 24))
                            .foregroundColor(Color("BittersweetOrange"))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(child.name)
                            .font(.custom("Outfit-Medium", size: 18))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("ID: \(child.studentId)")
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if let birthDate = child.birthDate {
                        Text(formatDate(birthDate))
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
                .padding(.top, 16)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

#Preview {
    ParentView()
}
