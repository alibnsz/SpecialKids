import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            LoginView()
        } else {
            VStack(spacing: 24) {
                Image("splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                
                VStack(spacing: 16) {
                    Text("Her birey eşsizdir, birlikte\nher engeli aşarız!")
                        .font(.custom("Outfit-Light", size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("OilBlack"))
                    
                    Text("Özel eğitim öğrencileri için tasarlanan bu uygulama, bireysel farklılıklara saygı duyarak, herkesin öğrenme yolculuğunu desteklemek için yanınızda.")
                        .font(.custom("Outfit-Light", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Text("© Copyright SpecialKids 2024.\nAll rights reserved")
                    .font(.custom("Outfit-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 20)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
} 
#Preview {
    SplashScreen()
}
