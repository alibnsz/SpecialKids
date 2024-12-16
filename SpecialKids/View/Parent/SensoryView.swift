import SwiftUI

struct SensoryView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle(isOn: $viewModel.hasSoundSensitivity) {
                Text("Belirli seslere karşı hassasiyet gösteriyor mu?")
                    .font(.custom("Outfit-Regular", size: 16))
            }
            
            if viewModel.hasSoundSensitivity {
                CustomTextField(
                    placeholder: "Hangi seslere karşı hassas?",
                    text: $viewModel.soundSensitivityDetails
                )
            }
            
            Toggle(isOn: $viewModel.hasTextureSensitivity) {
                Text("Belirli dokulara karşı hassasiyeti var mı?")
                    .font(.custom("Outfit-Regular", size: 16))
            }
            
            if viewModel.hasTextureSensitivity {
                CustomTextField(
                    placeholder: "Hangi dokulara karşı hassas?",
                    text: $viewModel.textureSensitivityDetails
                )
            }
        }
    }
} 