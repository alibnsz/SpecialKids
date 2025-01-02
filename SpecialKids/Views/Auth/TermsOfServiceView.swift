import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Kullanım Şartları")
                            .font(.custom("Outfit-Bold", size: 24))
                            .padding(.bottom, 10)
                        
                        Text("1. Genel Kurallar")
                            .font(.custom("Outfit-Medium", size: 18))
                        Text("Special Kids uygulamasını kullanarak aşağıdaki şartları kabul etmiş olursunuz. Uygulama, özel eğitim öğretmenleri ve veliler arasında iletişimi kolaylaştırmak için tasarlanmıştır.")
                            .font(.custom("Outfit-Regular", size: 14))
                        
                        Text("2. Gizlilik")
                            .font(.custom("Outfit-Medium", size: 18))
                        Text("Kullanıcıların kişisel bilgileri ve öğrenci verileri gizlilik politikamız kapsamında korunmaktadır. Veriler, yalnızca hizmet kalitesini artırmak için kullanılacaktır.")
                            .font(.custom("Outfit-Regular", size: 14))
                        
                        Text("3. Sorumluluklar")
                            .font(.custom("Outfit-Medium", size: 18))
                        Text("Kullanıcılar, platform üzerinden paylaştıkları içeriklerden sorumludur. Uygunsuz içerik paylaşımı durumunda hesap askıya alınabilir.")
                            .font(.custom("Outfit-Regular", size: 14))
                    }
                    
                    Group {
                        Text("4. Telif Hakları")
                            .font(.custom("Outfit-Medium", size: 18))
                        Text("Uygulama içeriğinin tüm hakları saklıdır. İçeriklerin izinsiz kullanımı yasaktır.")
                            .font(.custom("Outfit-Regular", size: 14))
                        
                        Text("5. Değişiklikler")
                            .font(.custom("Outfit-Medium", size: 18))
                        Text("Special Kids, kullanım şartlarında değişiklik yapma hakkını saklı tutar. Değişiklikler kullanıcılara bildirilecektir.")
                            .font(.custom("Outfit-Regular", size: 14))
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.custom("Outfit-Medium", size: 16))
                    .foregroundColor(Color("Plum"))
                }
            }
        }
    }
} 
