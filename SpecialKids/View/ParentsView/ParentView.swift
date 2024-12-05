import SwiftUI

struct ParentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var children: [Student] = []
    @State private var showAddChildSheet = false
    @State private var childName = ""
    @State private var childAge: Int = 0

    var body: some View {
        NavigationView {
            VStack {
                Text("Çocuklarım")
                    .font(.headline)
                
                if children.isEmpty {
                    Text("Henüz çocuk eklenmedi.")
                        .foregroundColor(.gray)
                } else {
                    List(children) { child in
                        NavigationLink(destination: HomeworkListView(child: child)) {
                            HStack {
                                Text(child.name)
                                Spacer()
                                Text("ID: \(child.id)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Button("Çocuk Ekle") {
                    showAddChildSheet = true
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $showAddChildSheet) {
                    VStack(spacing: 20) {
                        Text("Yeni Çocuk Ekle")
                            .font(.headline)

                        TextField("Çocuk Adı", text: $childName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        TextField("Çocuk Yaşı", value: $childAge, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)

                        Button("Çocuk Kaydet") {
                            saveChild()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Ebeveyn Paneli")
            .onAppear {
                fetchChildren()
            }
        }
    }
    
    private func fetchChildren() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        firebaseManager.fetchChildren(for: userId) { fetchedChildren, error in
            if let error = error {
                print("Çocuklar yüklenirken hata: \(error.localizedDescription)")
            } else if let fetchedChildren = fetchedChildren {
                self.children = fetchedChildren
            }
        }
    }

    private func saveChild() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        let childId = firebaseManager.generateRandomChildId()
        
        firebaseManager.addChildToParent(userId: userId, childId: childId, childName: childName, age: childAge) { error in
            if let error = error {
                print("Çocuk kaydedilirken hata: \(error.localizedDescription)")
            } else {
                fetchChildren()
                showAddChildSheet = false
            }
        }
    }
}
