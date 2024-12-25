import SwiftUI

struct CommunicationSkillsView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Çocuğunuz sözel olarak iletişim kurabiliyor mu?")
                .font(.custom("Outfit-Regular", size: 16))
            
            Picker("", selection: $viewModel.canCommunicateVerbally) {
                Text("Seçiniz").tag("")
                Text("Evet").tag("yes")
                Text("Kısmen").tag("partially")
                Text("Hayır").tag("no")
            }
            .pickerStyle(.segmented)
            
            Toggle(isOn: $viewModel.usesAlternativeCommunication) {
                Text("Alternatif bir iletişim yöntemi kullanıyor mu?")
                    .font(.custom("Outfit-Regular", size: 16))
            }
            
            if viewModel.usesAlternativeCommunication {
                CustomTextField(
                    placeholder: "Kullandığı yöntemi belirtiniz",
                    text: $viewModel.alternativeCommunicationDetails
                )
            }
        }
    }
} 