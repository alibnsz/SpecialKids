import SwiftUI
// Bildirim butonu için ayrı bir view
struct NotificationButtonView: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("BittersweetOrange"))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                )
            
            if count > 0 {
                Text("\(count)")
                    .font(.custom("Outfit-Bold", size: 12))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Circle().fill(Color("BittersweetOrange")))
                    .offset(x: 6, y: -6)
            }
        }
    }
}
