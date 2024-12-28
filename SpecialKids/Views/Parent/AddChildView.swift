import SwiftUI
import FirebaseFirestore

struct AddChildView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddChildViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress bar
                ProgressBar(currentStep: $viewModel.currentStep)
                    .padding(.top)
                
                // Başlık
                Text(viewModel.getCurrentTitle())
                    .font(.custom("Outfit-Bold", size: 24))
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                
                // İçerik
                ScrollView {
                    switch viewModel.currentStep {
                    case 1:
                        BasicInfoView(viewModel: viewModel)
                    case 2:
                        CommunicationSkillsView(viewModel: viewModel)
                    case 3:
                        SocialSkillsView(viewModel: viewModel)
                    case 4:
                        AcademicSkillsView(viewModel: viewModel)
                    case 5:
                        DailyLifeSkillsView(viewModel: viewModel)
                    case 6:
                        SensoryView(viewModel: viewModel)
                    case 7:
                        InterestsView(viewModel: viewModel)
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 24)
                
                // Navigasyon butonları
                HStack(spacing: 20) {
                    if viewModel.currentStep > 1 {
                        CustomButtonView(
                            title: "Geri",
                            type: .secondary
                        ) {
                            withAnimation {
                                viewModel.previousStep()
                            }
                        }
                    }
                    
                    CustomButtonView(
                        title: viewModel.currentStep == 7 ? "Tamamla" : "Devam Et",
                        type: .primary
                    ) {
                        withAnimation {
                            if viewModel.currentStep == 7 {
                                viewModel.saveChild()
                            } else {
                                viewModel.nextStep()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
            .navigationBarBackButtonHidden()
            .navigationBarItems(leading: 
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            )
            .alert("Başarılı!", isPresented: $viewModel.showSuccessAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Çocuk başarıyla eklendi.")
            }
        }
        #if compiler(>=5.9)
        .onChange(of: viewModel.navigateToParentView) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
        #else
        .onChange(of: viewModel.navigateToParentView) { newValue in
            if newValue {
                dismiss()
            }
        }
        #endif
    }
}

// Progress Bar
struct ProgressBar: View {
    @Binding var currentStep: Int
    let totalSteps = 7
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ? Color("BittersweetOrange") : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
        .padding(.horizontal)
    }
} 