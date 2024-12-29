import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ParentView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var children: [Student] = []
    @State private var showAddChildSheet = false
    @State private var showPremiumAlert = false
    @State private var showTargetSheet = false
    @State private var parentName: String = ""
    @State private var notifications: [Notification] = []
    @State private var showNotifications = false
    @State private var dailyTarget: TimeInterval = 30 * 60 // 30 dakika varsayılan değer
    
    private let horizontalPadding: CGFloat = 20
    
    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                // Üst başlık - Hoşgeldin mesajı
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hoşgeldin,")
                            .font(.custom("Outfit-Regular", size: 16))
                            .foregroundColor(.secondary)
                        Text(parentName)
                            .font(.custom("Outfit-SemiBold", size: 28))
                            .foregroundColor(Color("NeutralBlack"))
                    }
                    
                    Spacer()
                    
                    // Bildirim ve arama ikonları
                    HStack(spacing: 12) {
                        HeaderIconButton(icon: "magnifyingglass") {
                            // Arama işlemi
                        }
                        
                        NavigationLink {
                            NotificationsView(notifications: notifications)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            NotificationButtonView(count: notifications.count)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                
                if children.isEmpty {
                    EmptyStateView(showAddChildSheet: $showAddChildSheet)
                        .padding(.horizontal, horizontalPadding)
                } else {
                    ForEach(children) { child in
                        VStack(spacing: 20) {
                            // Süre hedef kartı
                            Button(action: { showTargetSheet = true }) {
                                DailyProgressCard(child: child, dailyTarget: dailyTarget)
                            }
                            
                            // Günlük aktiviteler
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Günlük Etkinlikler")
                                    .font(.custom("Outfit-SemiBold", size: 20))
                                
                                ActivityListView(child: child)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                }
            }
            .padding(.top, 16)
        }
        .background(Color.gray.opacity(0.05))
        .navigationBarHidden(true)
            .onAppear {
                fetchChildren()
            fetchParentName()
            fetchNotifications()
            fetchSavedDailyTarget()
        }
        .sheet(isPresented: $showTargetSheet) {
            TargetSettingSheet(dailyTarget: $dailyTarget)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAddChildSheet) {
            AddChildView()
        }
        .alert("Premium Hesap Gerekli", isPresented: $showPremiumAlert) {
            Button("Premium'a Geç", role: .none) {}
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Birden fazla çocuk eklemek için premium hesaba geçmeniz gerekmektedir.")
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView(notifications: notifications)
        }
    }
    
    private func fetchParentName() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("parents")
            .document(userId)
            .getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let name = data["name"] as? String {
                    self.parentName = name
            }
        }
    }
    
    private func fetchChildren() {
        guard let userId = firebaseManager.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("children")
            .whereField("parentId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching children: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    self.children = documents.compactMap { document -> Student? in
                        let data = document.data()
                        return Student(
                            id: document.documentID,
                            name: data["name"] as? String ?? "",
                            age: data["age"] as? Int ?? 0,
                            studentId: data["studentId"] as? String ?? "",
                            birthDate: (data["birthDate"] as? Timestamp)?.dateValue(),
                            isPremium: data["isPremium"] as? Bool ?? false
                        )
                    }
                }
            }
    }
    
    private func fetchNotifications() {
        guard let parentId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Task {
            do {
                let notifications = try await FirebaseManager.shared.fetchNotifications(for: parentId)
                await MainActor.run {
                    self.notifications = notifications
                }
            } catch {
                print("Error fetching notifications: \(error)")
            }
        }
    }
    
    private func fetchSavedDailyTarget() {
        FirebaseManager.shared.fetchDailyTarget { target in
            self.dailyTarget = target
        }
    }
}

// MARK: - Daily Progress Card
struct DailyProgressCard: View {
    let child: Student
    let dailyTarget: TimeInterval
    @State private var gameStats: GameStats?
    @State private var streak: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Üst kısım - Progress ve bilgi
            HStack(spacing: 24) {
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: min((gameStats?.dailyPlayTime ?? 0) / dailyTarget, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color("BittersweetOrange"),
                                    Color("FantasyPink")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(Int((gameStats?.dailyPlayTime ?? 0) / 60))")
                            .font(.custom("Outfit-Bold", size: 32))
                        Text("Dakika")
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Günlük hedef
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günlük Hedef")
                            .font(.custom("Outfit-Medium", size: 16))
                            .foregroundColor(.secondary)
                        Text("\(Int(dailyTarget / 60)) dakika")
                            .font(.custom("Outfit-SemiBold", size: 20))
                    }
                    
                    // Seri bilgisi
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            // Ateş efekti (animasyonsuz)
                            ForEach(0..<min(streak, 5), id: \.self) { _ in
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 16))
                            }
                            
                            Text("\(streak) Günlük Seri")
                                .font(.custom("Outfit-Medium", size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                        
                        Text("Seriyi korumak için her gün oyna")
                            .font(.custom("Outfit-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Alt kısım - Yıldızlar yerine ateşler (animasyonsuz)
            HStack(spacing: 12) {
                ForEach(0..<5) { index in
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(index < (gameStats?.score ?? 0) / 20 ? .orange : .gray.opacity(0.3))
                        .shadow(color: index < (gameStats?.score ?? 0) / 20 ? .orange.opacity(0.5) : .clear, radius: 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
        .onAppear {
            fetchGameStats()
            updateStreak()
        }
    }
    
    private func fetchGameStats() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("gameStats")
            .whereField("studentId", isEqualTo: child.id)
            .whereField("parentId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let lastPlayDate = (data["lastPlayDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Gün kontrolü
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let lastDate = calendar.startOfDay(for: lastPlayDate)
                    
                    // Eğer yeni bir gün başladıysa dailyPlayTime sıfırlanmalı
                    let dailyPlayTime = today == lastDate ? 
                        (data["dailyPlayTime"] as? TimeInterval ?? 0) : 0
                    
                    self.gameStats = GameStats(
                        correctMatches: data["correctMatches"] as? Int ?? 0,
                        wrongMatches: data["wrongMatches"] as? Int ?? 0,
                        score: data["score"] as? Int ?? 0,
                        lastPlayedDate: lastPlayDate,
                        fruits: [], // Diğer veriler aynı kalabilir
                        playTime: data["playTime"] as? TimeInterval ?? 0,
                        dailyPlayTime: dailyPlayTime, // Güncellenen dailyPlayTime
                        gameCompleted: data["gameCompleted"] as? Bool ?? false,
                        streak: data["streak"] as? Int ?? 0,
                        lastStreakDate: lastPlayDate,
                        studentId: child.id
                    )
                    
                    // Eğer yeni gün başladıysa, Firestore'da da güncelle
                    if today != lastDate {
                        document.reference.updateData([
                            "dailyPlayTime": 0,
                            "lastPlayDate": Timestamp(date: Date())
                        ])
                    }
                }
            }
    }
    
    private func updateStreak() {
        FirebaseManager.shared.updateStreak(for: child.id) { newStreak in
            self.streak = newStreak
        }
    }
}

// MARK: - Activity Section
struct ActivitySection: View {
    let child: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günlük Etkinlikler")
                .font(.custom("Outfit-SemiBold", size: 20))
            
            ActivityListView(child: child)
        }
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8)
                )
        }
    }
}

// MARK: - Activity List View
struct ActivityListView: View {
    let child: Student
    @State private var activities: [GameStats] = []
    @State private var showDetailedStats = false
    @State private var selectedActivity: GameStats?
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(activities, id: \.lastPlayedDate) { activity in
                Button(action: {
                    selectedActivity = activity
                    showDetailedStats = true
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Üst kısım - Başlık ve durum
                        HStack {
                            Text("Meyve Eşleştirme")
                                .font(.custom("Outfit-SemiBold", size: 16))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(activity.gameCompleted ? "TAMAMLANDI" : "TAMAMLANMADI")
                                .font(.custom("Outfit-Medium", size: 12))
                                .foregroundColor(activity.gameCompleted ? .green : .red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(activity.gameCompleted ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                        }
                        
                        // Alt kısım - İstatistikler
                        HStack(spacing: 16) {
                            // Süre
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("\(Int(activity.playTime / 60)) dk")
                                    .font(.custom("Outfit-Medium", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Puan
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text("\(activity.score) puan")
                                    .font(.custom("Outfit-Medium", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Tarih
                            Text(formatDate(activity.lastPlayedDate))
                                .font(.custom("Outfit-Regular", size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                    )
                }
            }
        }
        .sheet(isPresented: $showDetailedStats) {
            if let activity = selectedActivity {
                GameDetailView(stats: activity, childName: child.name)
            }
        }
        .onAppear {
            fetchActivities()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func fetchActivities() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("gameStats")
            .whereField("studentId", isEqualTo: child.id)
            .whereField("parentId", isEqualTo: userId)
            .order(by: "lastPlayedDate", descending: true)
            .addSnapshotListener { snapshot, error in
                if let documents = snapshot?.documents {
                    self.activities = documents.compactMap { document in
                        let data = document.data()
                        
                        let fruitsData = data["fruits"] as? [[String: Any]] ?? []
                        let fruits = fruitsData.map { fruitData in
                            FruitMatchResult(
                                fruitName: fruitData["fruitName"] as? String ?? "",
                                isCorrect: fruitData["isCorrect"] as? Bool ?? false,
                                attemptCount: fruitData["attemptCount"] as? Int ?? 0
                            )
                        }
                        
                        return GameStats(
                            correctMatches: data["correctMatches"] as? Int ?? 0,
                            wrongMatches: data["wrongMatches"] as? Int ?? 0,
                            score: data["score"] as? Int ?? 0,
                            lastPlayedDate: (data["lastPlayedDate"] as? Timestamp)?.dateValue() ?? Date(),
                            fruits: fruits,
                            playTime: data["playTime"] as? TimeInterval ?? 0,
                            dailyPlayTime: data["dailyPlayTime"] as? TimeInterval ?? 0,
                            gameCompleted: data["gameCompleted"] as? Bool ?? false,
                            streak: data["streak"] as? Int ?? 0,
                            lastStreakDate: (data["lastStreakDate"] as? Timestamp)?.dateValue() ?? Date(),
                            studentId: data["studentId"] as? String ?? ""
                        )
                    }
                }
            }
    }
}

// MARK: - Game Detail View
struct GameDetailView: View {
    let stats: GameStats
    let childName: String
    @Environment(\.dismiss) private var dismiss
    @State private var previousGames: [GameStats] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Başarı oranı çemberi
                    CircularProgressView(stats: stats)
                        .frame(height: 200)
                    
                    // Oyun özeti
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Oyun Özeti")
                            .font(.custom("Outfit-SemiBold", size: 18))
                        
                        VStack(spacing: 12) {
                            SummaryRow(title: "Durum", value: stats.gameCompleted ? "Tamamlandı" : "Tamamlanmadı", color: stats.gameCompleted ? .green : .red)
                            SummaryRow(title: "Toplam Puan", value: "\(stats.score)")
                            SummaryRow(title: "Oynama Süresi", value: "\(Int(stats.playTime / 60)) dakika")
                            SummaryRow(title: "Doğru Eşleşme", value: "\(stats.correctMatches)")
                            SummaryRow(title: "Yanlış Eşleşme", value: "\(stats.wrongMatches)")
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // Meyve bazlı performans
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Meyve Detayları")
                            .font(.custom("Outfit-SemiBold", size: 18))
                        
                        ForEach(stats.fruits, id: \.fruitName) { fruit in
                            HStack {
                                Text(fruit.fruitName)
                                    .font(.custom("Outfit-Medium", size: 16))
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: fruit.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(fruit.isCorrect ? .green : .red)
                                    
                                    Text("\(fruit.attemptCount) deneme")
                                        .font(.custom("Outfit-Regular", size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // Önceki oyunlar
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Önceki Oyunlar")
                            .font(.custom("Outfit-SemiBold", size: 18))
                        
                        if previousGames.isEmpty {
                            Text("Henüz başka oyun kaydı bulunmuyor")
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(previousGames.sorted(by: { $0.lastPlayedDate > $1.lastPlayedDate }), id: \.lastPlayedDate) { game in
                                PreviousGameCard(game: game)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                }
                .padding()
            }
            .navigationTitle("\(childName) - Oyun Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            fetchPreviousGames()
        }
    }
    
    private func fetchPreviousGames() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("gameStats")
            .whereField("studentId", isEqualTo: stats.studentId)
            .whereField("parentId", isEqualTo: userId)
            .order(by: "lastPlayedDate", descending: true)
            .limit(to: 10) // Son 10 oyun
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.previousGames = documents.compactMap { document in
                        let data = document.data()
                        
                        let fruitsData = data["fruits"] as? [[String: Any]] ?? []
                        let fruits = fruitsData.map { fruitData in
                            FruitMatchResult(
                                fruitName: fruitData["fruitName"] as? String ?? "",
                                isCorrect: fruitData["isCorrect"] as? Bool ?? false,
                                attemptCount: fruitData["attemptCount"] as? Int ?? 0
                            )
                        }
                        
                        return GameStats(
                            correctMatches: data["correctMatches"] as? Int ?? 0,
                            wrongMatches: data["wrongMatches"] as? Int ?? 0,
                            score: data["score"] as? Int ?? 0,
                            lastPlayedDate: (data["lastPlayedDate"] as? Timestamp)?.dateValue() ?? Date(),
                            fruits: fruits,
                            playTime: data["playTime"] as? TimeInterval ?? 0,
                            dailyPlayTime: data["dailyPlayTime"] as? TimeInterval ?? 0,
                            gameCompleted: data["gameCompleted"] as? Bool ?? false,
                            streak: data["streak"] as? Int ?? 0,
                            lastStreakDate: (data["lastStreakDate"] as? Timestamp)?.dateValue() ?? Date(),
                            studentId: data["studentId"] as? String ?? ""
                        )
                    }
                }
            }
    }
}

struct PreviousGameCard: View {
    let game: GameStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Üst kısım - Tarih ve durum
            HStack {
                Text(formatDate(game.lastPlayedDate))
                    .font(.custom("Outfit-Regular", size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(game.gameCompleted ? "TAMAMLANDI" : "TAMAMLANMADI")
                    .font(.custom("Outfit-Medium", size: 12))
                    .foregroundColor(game.gameCompleted ? .green : .red)
            }
            
            Divider()
            
            // Alt kısım - İstatistikler
            HStack(spacing: 16) {
                StatItem(title: "Puan", value: "\(game.score)", icon: "star.fill", color: .orange)
                StatItem(title: "Süre", value: "\(Int(game.playTime / 60)) dk", icon: "clock.fill", color: .blue)
                StatItem(title: "Doğru", value: "\(game.correctMatches)", icon: "checkmark.circle.fill", color: .green)
                StatItem(title: "Yanlış", value: "\(game.wrongMatches)", icon: "xmark.circle.fill", color: .red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.custom("Outfit-SemiBold", size: 14))
            
            Text(title)
                .font(.custom("Outfit-Regular", size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Outfit-Regular", size: 16))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.custom("Outfit-Medium", size: 16))
                .foregroundColor(color)
        }
    }
}

// MARK: - Target Setting Sheet
struct TargetSettingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTarget: Int = 16
    @Binding var dailyTarget: TimeInterval
    
    private func saveTarget() {
        let targetInSeconds = TimeInterval(selectedTarget * 60)
        dailyTarget = targetInSeconds
        FirebaseManager.shared.saveDailyTarget(minutes: targetInSeconds)
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Günlük Hedef Belirle")
                    .font(.custom("Outfit-Bold", size: 24))
                    .multilineTextAlignment(.center)
                
                Text("Çocuğunuzun gelişimi için düzenli uygulama kalıcı sonuçlar sağlayacaktır. Günde en az 16 dakika pratik yapması tavsiye edilir.")
                    .font(.custom("Outfit-ExtraLight", size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Picker("Dakika", selection: $selectedTarget) {
                    ForEach([8, 16, 30], id: \.self) { minute in
                        Text("\(minute) dakika")
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                
                CustomButtonView(title: "Kaydet", type: .secondary) {
                    saveTarget()
                }
                .padding()

            }
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

// MARK: - Empty State View
struct EmptyStateView: View {
    @Binding var showAddChildSheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image("")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.top, 40)
            
            VStack(spacing: 12) {
                Text("Henüz çocuk eklenmedi")
                    .font(.custom("Outfit-SemiBold", size: 20))
                    .foregroundColor(.primary)
                
                Text("İlk çocuğunuzu ekleyerek özel eğitim yolculuğuna başlayın")
                    .font(.custom("Outfit-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            CustomButtonView(
                title: "Çocuk Ekle",
                type: .primary
            ) {
                showAddChildSheet = true
            }
            .frame(maxWidth: 200)
        }
        .padding()
    }
}

// MARK: - Child Card View
struct ChildCardView: View {
    let child: Student
    @State private var gameStats: GameStats?
    @State private var showDetailedStats = false
    
    private let dailyTarget: TimeInterval = 30 * 60 // 30 dakika (saniye cinsinden)
    
    var body: some View {
        Button(action: {
            showDetailedStats = true
        }) {
            VStack(spacing: 16) {
                // Üst kısım - Çocuk bilgileri
                HStack(alignment: .center, spacing: 16) {
                    // Profil circle
                Circle()
                    .fill(Color("BittersweetOrange").opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(child.name.prefix(1).uppercased())
                            .font(.custom("Outfit-SemiBold", size: 24))
                            .foregroundColor(Color("BittersweetOrange"))
                    )
                
                    VStack(alignment: .leading, spacing: 4) {
                        Text(child.name)
                            .font(.custom("Outfit-Medium", size: 18))
                            .foregroundColor(.primary)
                        
                        if let birthDate = child.birthDate {
                            Text(formatDate(birthDate))
                                .font(.custom("Outfit-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                        
                        Spacer()
                    
                    // Sağ tarafta ok işareti
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                if let stats = gameStats {
                    // Günlük oyun süresi progress circle
                    HStack(spacing: 20) {
                        // Sol taraf - Progress Circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: min(stats.dailyPlayTime / dailyTarget, 1.0))
                                .stroke(
                                    stats.dailyPlayTime >= dailyTarget ? Color.green : Color("BittersweetOrange"),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 2) {
                                Text("\(formatMinutes(Int(stats.dailyPlayTime / 60)))")
                                    .font(.custom("Outfit-SemiBold", size: 16))
                                Text("dk")
                                    .font(.custom("Outfit-Regular", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Sağ taraf - İstatistikler
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.green)
                                Text("Günlük Hedef: 30 dk")
                            .font(.custom("Outfit-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.orange)
                                Text("\(stats.score) puan")
                                    .font(.custom("Outfit-Medium", size: 14))
                            }
                        }
                        
                        Spacer()
                    }
                }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailedStats) {
            DetailedStatsView(stats: gameStats, childName: child.name)
        }
        .onAppear {
            fetchGameStats()
        }
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        return "\(minutes)"
    }
    
    private func fetchGameStats() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        Firestore.firestore().collection("gameStats")
            .whereField("studentId", isEqualTo: child.id)
            .whereField("parentId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let lastPlayDate = (data["lastPlayDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Gün kontrolü
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let lastDate = calendar.startOfDay(for: lastPlayDate)
                    
                    // Eğer yeni bir gün başladıysa dailyPlayTime sıfırlanmalı
                    let dailyPlayTime = today == lastDate ? 
                        (data["dailyPlayTime"] as? TimeInterval ?? 0) : 0
                    
                    self.gameStats = GameStats(
                        correctMatches: data["correctMatches"] as? Int ?? 0,
                        wrongMatches: data["wrongMatches"] as? Int ?? 0,
                        score: data["score"] as? Int ?? 0,
                        lastPlayedDate: lastPlayDate,
                        fruits: [], // Diğer veriler aynı kalabilir
                        playTime: data["playTime"] as? TimeInterval ?? 0,
                        dailyPlayTime: dailyPlayTime, // Güncellenen dailyPlayTime
                        gameCompleted: data["gameCompleted"] as? Bool ?? false,
                        streak: data["streak"] as? Int ?? 0,
                        lastStreakDate: lastPlayDate,
                        studentId: child.id
                    )
                    
                    // Eğer yeni gün başladıysa, Firestore'da da güncelle
                    if today != lastDate {
                        document.reference.updateData([
                            "dailyPlayTime": 0,
                            "lastPlayDate": Timestamp(date: Date())
                        ])
                    }
                }
            }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// MARK: - Progress Bar View
struct ProgressBarView: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    
    var progress: Double {
        total > 0 ? value / total : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.custom("Outfit-Regular", size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(value))")
                    .font(.custom("Outfit-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
}

// MARK: - Detailed Stats View
struct DetailedStatsView: View {
    let stats: GameStats?
    let childName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let stats = stats {
                    VStack(spacing: 24) {
                        // Ana performans göstergesi
                        CircularProgressView(stats: stats)
                            .frame(height: 200)
                            .padding(.top)
                        
                        // Oyun detayları
                        GameDetailsCard(stats: stats)
                        
                        // Meyve bazlı performans
                        FruitPerformanceCard(fruits: stats.fruits)
                        
                        // Zaman bazlı analiz
                        TimeAnalysisCard(stats: stats)
                    }
                    .padding()
                } else {
                    EmptyStatsView()
                }
            }
            .navigationTitle("\(childName) Performans Raporu")
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

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let stats: GameStats
    @State private var progress: CGFloat = 0
    
    private var successRate: Double {
        let total = Double(stats.correctMatches + stats.wrongMatches)
        return total > 0 ? Double(stats.correctMatches) / total : 0
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Arka plan çemberi
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // İlerleme çemberi
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color("BittersweetOrange"), .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // Merkez metin
                VStack(spacing: 4) {
                    Text("\(Int(successRate * 100))%")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("BittersweetOrange"))
                    
                    Text("Başarı Oranı")
                        .font(.custom("Outfit-Medium", size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    progress = successRate
                }
            }
        }
    }
}

// MARK: - Game Details Card
struct GameDetailsCard: View {
    let stats: GameStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Oyun Detayları")
                .font(.custom("Outfit-SemiBold", size: 18))
            
            HStack(spacing: 20) {
                DetailBox(
                    title: "Toplam Puan",
                    value: "\(stats.score)",
                    icon: "star.fill",
                    color: .orange
                )
                
                DetailBox(
                    title: "Doğru",
                    value: "\(stats.correctMatches)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                DetailBox(
                    title: "Yanlış",
                    value: "\(stats.wrongMatches)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

// MARK: - Fruit Performance Card
struct FruitPerformanceCard: View {
    let fruits: [FruitMatchResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meyve Bazlı Performans")
                .font(.custom("Outfit-SemiBold", size: 18))
            
            VStack(spacing: 12) {
                ForEach(fruits.sorted(by: { $0.attemptCount > $1.attemptCount }), id: \.fruitName) { fruit in
                    FruitPerformanceRow(fruit: fruit)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct FruitPerformanceRow: View {
    let fruit: FruitMatchResult
    
    var body: some View {
        HStack {
            Text(fruit.fruitName)
                .font(.custom("Outfit-Medium", size: 16))
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: fruit.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(fruit.isCorrect ? .green : .red)
                
                Text("\(fruit.attemptCount) deneme")
                    .font(.custom("Outfit-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Time Analysis Card
struct TimeAnalysisCard: View {
    let stats: GameStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Zaman Analizi")
                .font(.custom("Outfit-SemiBold", size: 18))
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color("BittersweetOrange"))
                    
                    Text("Son Oynanma:")
                        .font(.custom("Outfit-Medium", size: 16))
                    
                    Spacer()
                    
                    Text(formatDate(stats.lastPlayedDate))
                        .font(.custom("Outfit-Regular", size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct DetailBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
            }
            
            Text(value)
                .font(.custom("Outfit-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.custom("Outfit-Regular", size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Henüz oyun istatistiği bulunmuyor")
                .font(.custom("Outfit-Medium", size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Header Icon Button
struct HeaderIconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("BittersweetOrange"))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 15,
                            x: 0,
                            y: 5
                        )
                )
        }
    }
}


#Preview {
    ParentView()
}
