import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 1
    
    let features = [
        PremiumFeature(
            icon: "person.2.fill",
            title: "Sınırsız Çocuk",
            description: "Birden fazla çocuğunuz için özel eğitim imkanı"
        ),
        PremiumFeature(
            icon: "brain.head.profile",
            title: "Yapay Zeka",
            description: "Kişiselleştirilmiş öğrenme deneyimi"
        ),
        PremiumFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Detaylı Raporlar",
            description: "Gelişim takibi ve performans analizleri"
        ),
        PremiumFeature(
            icon: "gamecontroller.fill",
            title: "Özel Oyunlar",
            description: "Premium kullanıcılara özel eğitici oyunlar"
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan
                Color("Plum").opacity(0.05).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Premium Header
                        VStack(spacing: 20) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(colors: [.yellow, .orange],
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                )
                                .shadow(color: .orange.opacity(0.3), radius: 10)
                            
                            Text("Premium Deneyim")
                                .font(.custom("Outfit-Bold", size: 28))
                                .foregroundColor(Color("NeutralBlack"))
                            
                            Text("Çocuğunuzun eğitim yolculuğunu\nbir üst seviyeye taşıyın")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Premium özellikleri
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Premium Ayrıcalıkları")
                                .font(.custom("Outfit-SemiBold", size: 20))
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                ForEach(features) { feature in
                                    FeatureRow(feature: feature)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Plan seçimi
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Plan Seçin")
                                .font(.custom("Outfit-SemiBold", size: 20))
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                PlanCard(
                                    isSelected: selectedPlan == 1,
                                    title: "Yıllık Premium",
                                    price: "29.99",
                                    period: "ay",
                                    savings: "40% tasarruf",
                                    totalPrice: "359.88/yıl",
                                    isRecommended: true,
                                    action: { withAnimation { selectedPlan = 1 } }
                                )
                                
                                PlanCard(
                                    isSelected: selectedPlan == 0,
                                    title: "Aylık Premium",
                                    price: "49.99",
                                    period: "ay",
                                    action: { withAnimation { selectedPlan = 0 } }
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Alt bilgi ve buton
                        VStack(spacing: 24) {
                            // Deneme bilgisi
                            HStack(spacing: 32) {
                                InfoBadge(
                                    icon: "clock.fill",
                                    text: "7 Gün Ücretsiz"
                                )
                                
                                InfoBadge(
                                    icon: "arrow.uturn.backward.circle.fill",
                                    text: "İptal Garantisi"
                                )
                            }
                            
                            // Premium'a geç butonu
                            Button(action: {
                                // Premium işlemi
                            }) {
                                Text("Premium'a Geç")
                                    .font(.custom("Outfit-Bold", size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [Color("Plum"), Color("BittersweetOrange")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(
                                        color: Color("Plum").opacity(0.3),
                                        radius: 8,
                                        y: 4
                                    )
                            }
                            
                            // Kullanım koşulları
                            Text("Aboneliğiniz otomatik olarak yenilenir.\nİstediğiniz zaman iptal edebilirsiniz.")
                                .font(.custom("Outfit-Regular", size: 12))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.custom("Outfit-Medium", size: 14))
        }
        .foregroundColor(.green)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("Plum"))
                .frame(width: 44, height: 44)
                .background(Color("Plum").opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.custom("Outfit-SemiBold", size: 16))
                
                Text(feature.description)
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 8)
    }
}

struct PlanCard: View {
    let isSelected: Bool
    let title: String
    let price: String
    let period: String
    var savings: String? = nil
    var totalPrice: String? = nil
    var isRecommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if isRecommended {
                    Text("En Avantajlı")
                        .font(.custom("Outfit-Medium", size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.custom("Outfit-SemiBold", size: 16))
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.custom("Outfit-Medium", size: 14))
                                .foregroundColor(.green)
                        }
                        
                        if let totalPrice = totalPrice {
                            Text(totalPrice)
                                .font(.custom("Outfit-Regular", size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("₺\(price)")
                            .font(.custom("Outfit-Bold", size: 24))
                        Text("/\(period)")
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("Plum") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
} 
