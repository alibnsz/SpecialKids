import SwiftUI

struct BasicInfoView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            CustomTextField(placeholder: "Adı ve Soyadı", text: $viewModel.name)
            
            DatePicker(
                "Doğum Tarihi",
                selection: $viewModel.birthDate,
                displayedComponents: .date
            )
            .font(.custom("Outfit-Regular", size: 16))
            
            Picker("Cinsiyet", selection: $viewModel.gender) {
                Text("Seçiniz").tag("")
                Text("Kız").tag("female")
                Text("Erkek").tag("male")
            }
            .pickerStyle(.segmented)
            
            Toggle(isOn: $viewModel.hasDiagnosis) {
                Text("Tanı konmuş bir durum var mı?")
                    .font(.custom("Outfit-Regular", size: 16))
            }
            
            if viewModel.hasDiagnosis {
                CustomTextField(
                    placeholder: "Tanı detaylarını giriniz",
                    text: $viewModel.diagnosisDetails
                )
            }
        }
    }
} 
