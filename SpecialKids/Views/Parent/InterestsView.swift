import SwiftUI

struct InterestsView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Çocuğunuzun en çok ilgisini çeken şeyler nelerdir?")
                .font(.custom("Outfit-Regular", size: 16))
            
            CustomTextField(
                placeholder: "Örnek: arabalar, hayvanlar, çizgi filmler",
                text: $viewModel.interests
            )
            
            Text("Çocuğunuz oyun oynarken hangi tür oyuncakları tercih eder?")
                .font(.custom("Outfit-Regular", size: 16))
            
            CustomTextField(
                placeholder: "Tercih ettiği oyuncakları yazınız",
                text: $viewModel.preferredToys
            )
        }
    }
} 