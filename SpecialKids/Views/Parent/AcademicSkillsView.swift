import SwiftUI

struct AcademicSkillsView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Toggle(isOn: $viewModel.canRecognizeLetters) {
                    Text("Harfleri tanıyabiliyor mu?")
                        .font(.custom("Outfit-Regular", size: 16))
                }
                
                Toggle(isOn: $viewModel.canRecognizeNumbers) {
                    Text("Rakamları tanıyabiliyor mu?")
                        .font(.custom("Outfit-Regular", size: 16))
                }
            }
            
            Group {
                Toggle(isOn: $viewModel.canUnderstandStories) {
                    Text("Kısa hikayeler dinlediğinde anlayabiliyor mu?")
                        .font(.custom("Outfit-Regular", size: 16))
                }
                
                Toggle(isOn: $viewModel.canFollowInstructions) {
                    Text("Basit talimatları anlayabiliyor mu?")
                        .font(.custom("Outfit-Regular", size: 16))
                }
            }
        }
    }
} 