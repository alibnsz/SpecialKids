import SwiftUI

struct ClassManagementView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var classes: [SchoolClass] = []
    @State private var newClassName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedClass: SchoolClass?
    
    var isFormValid: Bool {
        !newClassName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sinif Secin")
                    .font(.custom(outfitMedium, size: 24))
                    .padding(.top, 20)
                
                // Existing classes dropdown
                Menu {
                    if classes.isEmpty {
                        Text("Henüz bir sınıf oluşturmadınız.")
                            .font(.custom(outfitLight, size: 16))
                            .foregroundColor(.gray)
                    } else {
                        ForEach(classes) { schoolClass in
                            Button(action: {
                                selectedClass = schoolClass
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text(schoolClass.name)
                                    .font(.custom(outfitRegular, size: 16))
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedClass?.name ?? "Sinif Adi")
                            .font(.custom(outfitRegular, size: 16))
                            .foregroundColor(selectedClass == nil ? Color.gray.opacity(0.5) : Color.gray.opacity(0.9))
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color("OilBlack"))
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("OilBlack"), lineWidth: 1)
                    )
                }
                .disabled(isLoading)
                .padding(.horizontal, 20)

                Text("veya")
                    .font(.custom(outfitLight, size: 16))
                    .foregroundColor(.gray)
                
                Text("Sinif olusturmak icin asagidaki alana sinif adini girin.")
                    .font(.custom(outfitLight, size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Sinif Adi",
                        text: $newClassName
                    )
                    .disabled(isLoading)
                    
                    CustomButtonView(
                        title: "Sınıf Oluştur",
                        isLoading: isLoading,
                        disabled: !isFormValid,
                        type: .secondary
                    ) {
                        addClass()
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .onAppear(perform: fetchClasses)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
    }
    
    private func addClass() {
        guard isFormValid else { return }
        
        isLoading = true
        guard let teacherId = firebaseManager.auth.currentUser?.uid else {
            alertMessage = "Öğretmen bilgisi bulunamadı"
            showAlert = true
            isLoading = false
            return
        }
        
        firebaseManager.createClassForTeacher(teacherId: teacherId, name: newClassName) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Sınıf oluşturulurken hata oluştu: \(error.localizedDescription)"
            } else {
                alertMessage = "Sınıf başarıyla oluşturuldu"
                newClassName = ""
                fetchClasses()
            }
            showAlert = true
        }
    }
    
    private func fetchClasses() {
        guard let teacherId = firebaseManager.auth.currentUser?.uid else { return }
        
        isLoading = true
        firebaseManager.fetchClassesForTeacher(teacherId: teacherId) { fetchedClasses, error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Sınıflar yüklenirken hata oluştu: \(error.localizedDescription)"
                showAlert = true
            } else if let fetchedClasses = fetchedClasses {
                classes = fetchedClasses
            }
        }
    }
}
