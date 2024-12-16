import SwiftUI

struct DailyLifeSkillsView: View {
    @ObservedObject var viewModel: AddChildViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Yemek yerken veya su içerken yardıma ihtiyaç duyuyor mu?")
                .font(.custom("Outfit-Regular", size: 16))
            
            Picker("", selection: $viewModel.needsHelpEating) {
                Text("Seçiniz").tag("")
                Text("Evet").tag("yes")
                Text("Kısmen").tag("partially")
                Text("Hayır").tag("no")
            }
            .pickerStyle(.segmented)
            
            Text("Tuvalet ihtiyacını bağımsız olarak karşılayabiliyor mu?")
                .font(.custom("Outfit-Regular", size: 16))
            
            Picker("", selection: $viewModel.toiletIndependence) {
                Text("Seçiniz").tag("")
                Text("Evet").tag("yes")
                Text("Kısmen").tag("partially")
                Text("Hayır").tag("no")
            }
            .pickerStyle(.segmented)
        }
    }
} 