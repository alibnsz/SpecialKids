import SwiftUI

struct SocialSkillsView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Çocuğunuz diğer insanlarla iletişim kurarken zorlanıyor mu?")
                .font(.custom("Outfit-Regular", size: 16))
            
            Picker("", selection: $viewModel.socialInteractionDifficulty) {
                Text("Seçiniz").tag("")
                Text("Evet").tag("yes")
                Text("Hayır").tag("no")
                Text("Bazen").tag("sometimes")
            }
            .pickerStyle(.segmented)
            
            Text("Oyun oynarken diğer çocuklarla etkileşim kurmayı tercih ediyor mu?")
                .font(.custom("Outfit-Regular", size: 16))
            
            Picker("", selection: $viewModel.playsWithOthers) {
                Text("Seçiniz").tag("")
                Text("Evet").tag("yes")
                Text("Hayır").tag("no")
                Text("Bazen").tag("sometimes")
            }
            .pickerStyle(.segmented)
        }
    }
} 