import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseAppCheck


// MARK: - Firebase Manager
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    var auth = Auth.auth()
    let db = Firestore.firestore()
    
    // Auth state listener'ı saklamak için
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    @Published var currentUserRole: String? = nil
    @Published var isAuthenticated = false
    @Published var classes: [SchoolClass] = []
    @Published var studentIdToAdd: String? = nil

    init() {
        // UserDefaults'dan kayıtlı oturum bilgilerini kontrol et
        checkSavedSession()
        
        // Auth state değişikliklerini dinle ve listener'ı sakla
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.saveUserSession(userId: user.uid)
                    self?.fetchUserRole(userId: user.uid)
                }
            }
        }
    }
    
    deinit {
        // Listener'ı temizle
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    private func checkSavedSession() {
        if let _ = UserDefaults.standard.string(forKey: "userId"),
           let role = UserDefaults.standard.string(forKey: "userRole") {
            // Kayıtlı oturum varsa Firebase'e otomatik giriş yap
            self.currentUserRole = role
            self.isAuthenticated = true
        }
    }
    
    private func saveUserSession(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    private func fetchUserRole(userId: String) {
        // Önce parent koleksiyonunda ara
        db.collection("parents").document(userId).getDocument { [weak self] document, error in
            if document?.exists == true {
                DispatchQueue.main.async {
                    self?.currentUserRole = "parent"
                    UserDefaults.standard.set("parent", forKey: "userRole")
                }
                return
            }
            
            // Parent değilse teacher koleksiyonunda ara
            self?.db.collection("teachers").document(userId).getDocument { document, error in
                DispatchQueue.main.async {
                    if document?.exists == true {
                        self?.currentUserRole = "teacher"
                        UserDefaults.standard.set("teacher", forKey: "userRole")
                    }
                }
            }
        }
    }
    
    // MARK: - Sınıf Oluşturma
    func createClass(name: String, teacherId: String, completion: @escaping (Error?) -> Void) {
        let newClass = SchoolClass(id: UUID().uuidString, name: name, teacherId: teacherId, students: [])
        db.collection("classes").document(newClass.id).setData([
            "id": newClass.id,
            "name": name,
            "teacherId": teacherId,
            "students": [] // Boş öğrenci listesi ile başlatıyoruz
        ]) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.classes.append(newClass) // Yeni sınıfı array'e ekliyoruz
                }
                completion(error)
            }
        }
    }
    // MARK: - Çocukları Al
    func fetchChildren(for parentId: String, completion: @escaping ([Student]?, Error?) -> Void) {
        db.collection("parents").document(parentId).collection("children")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Çocuklar çekilemedi: \(error.localizedDescription)")
                    completion(nil, error)
                } else {
                    let children = snapshot?.documents.compactMap { document -> Student? in
                        let data = document.data()
                        let childId = document.documentID
                        let name = data["name"] as? String ?? ""
                        let age = data["age"] as? Int ?? 0
                        let studentId = data["studentId"] as? String ?? self.generateRandomChildId()
                        let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
                        
                        return Student(
                            id: childId,
                            name: name,
                            age: age,
                            studentId: studentId,
                            birthDate: birthDate
                        )
                    }
                    completion(children, nil)
                }
            }
    }
    // MARK: - Öğrencinin Velisini Al
    func fetchParentForStudent(studentId: String, completion: @escaping (String?) -> Void) {
        print("Searching parent for student: \(studentId)") // Debug log
        
        db.collection("children")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding parent: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let document = snapshot?.documents.first,
                   let parentId = document.data()["parentId"] as? String {
                    print("Found parent ID: \(parentId)") // Debug log
                    completion(parentId)
                } else {
                    print("No parent found for student: \(studentId)")
                    completion(nil)
                }
            }
    }
    // MARK: - Çocuk Ekleme
    func addChildToParent(userId: String, childId: String, childName: String, age: Int, completion: @escaping (Error?) -> Void) {
        let studentId = generateRandomChildId()
        print("Yeni oluşturulan 6 haneli ID: \(studentId)")
        
        let childData: [String: Any] = [
            "id": childId,
            "name": childName,
            "age": age,
            "studentId": studentId,
            "parentId": userId,
            "createdAt": Timestamp()
        ]
        
        // Ana children koleksiyonuna ekle
        db.collection("children").document(childId).setData(childData) { error in
            if let error = error {
                print("Children koleksiyonuna ekleme hatası: \(error)")
                completion(error)
                return
            }
            
            print("Çocuk başarıyla eklendi - StudentID: \(studentId)")
            completion(nil)
        }
    }
    // MARK: - Sınıf Yükleme
    func fetchClasses(completion: @escaping (Error?) -> Void) {
        db.collection("classes").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            if let documents = snapshot?.documents {
                self.classes = documents.compactMap { try? $0.data(as: SchoolClass.self) }
            }
            completion(nil)
        }
    }
    // MARK: - Ödev İşlemleri
    func assignHomework(homework: Homework, completion: @escaping (Error?) -> Void) {
        let homeworkData: [String: Any] = [
            "id": homework.id,
            "title": homework.title,
            "description": homework.description,
            "dueDate": Timestamp(date: homework.dueDate),
            "studentId": homework.studentId,
            "teacherId": homework.teacherId ?? auth.currentUser?.uid ?? "",
            "status": homework.status.rawValue,
            "assignedDate": Timestamp(date: homework.assignedDate)
        ]
        
        // Önce ödevi kaydet
        db.collection("homework").document(homework.id).setData(homeworkData) { [weak self] error in
            if let error = error {
                completion(error)
                return
            }
            
            // Ödev kaydedildikten sonra bildirim oluştur
            Task {
                await self?.sendHomeworkNotification(
                    homework: homework,
                    parentId: homework.studentId
                )
            }
            
            completion(nil)
        }
    }
    func fetchHomeworkForStudent(studentId: String, completion: @escaping ([Homework]?, Error?) -> Void) {
        db.collection("homework")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let homeworks = snapshot?.documents.compactMap { document -> Homework? in
                    let data = document.data()
                    return Homework(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        dueDate: (data["dueDate"] as? Timestamp)?.dateValue() ?? Date(),
                        studentId: data["studentId"] as? String ?? "",
                        teacherId: data["teacherId"] as? String,
                        status: HomeworkStatus(rawValue: data["status"] as? String ?? "") ?? .pending,
                        assignedDate: (data["assignedDate"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                completion(homeworks, nil)
            }
    }
    func fetchAssignmentsForStudent(studentId: String, completion: @escaping ([Assignment]?, Error?) -> Void) {
        fetchHomeworkForStudent(studentId: studentId, completion: completion)
    }
    func fetchHomeworks(for parentId: String, completion: @escaping ([Homework]?, Error?) -> Void) {
        // Önce ebeveynin çocuklarını çek
        fetchChildren(for: parentId) { children, error in
            if let error = error {
                completion(nil, error)
            } else if let children = children {
                // Çocukların ID'lerini kontrol et
                let studentIds = children.map { $0.id }
                print("Ebeveynin çocukları: \(studentIds)") // Konsola çocukların ID'lerini yazdır

                var homeworks: [Homework] = []
                let dispatchGroup = DispatchGroup()

                for studentId in studentIds {
                    dispatchGroup.enter()
                    self.fetchAssignmentsForStudent(studentId: studentId) { studentHomeworks, error in
                        if let studentHomeworks = studentHomeworks {
                            homeworks.append(contentsOf: studentHomeworks)
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("Ebeveyn için çekilen tüm ödevler: \(homeworks)") // Tüm ödevlerin listesini yazdır
                    completion(homeworks, nil)
                }
            }
        }
    }
    // MARK: - Öğrenci Ekleme
    func addStudentToClass(classId: String, studentId: String, completion: @escaping (Error?) -> Void) {
        print("Sınıfa eklenecek öğrenci ID'si: \(studentId)")
        
        // Önce öğrenciyi bul
        checkStudentId(studentId: studentId) { student, error in
            if let error = error {
                print("Öğrenci arama hatası: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let student = student else {
                print("Öğrenci bulunamadı")
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Öğrenci bulunamadı"]))
                return
            }
            
            print("Bulunan öğrenci: \(student)")
            
            // Sınıfa öğrenciyi ekle (document ID'yi kullanarak)
            let classRef = self.db.collection("classes").document(classId)
            classRef.getDocument { document, error in
                if let error = error {
                    print("Sınıf getirme hatası: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Sınıf bulunamadı")
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sınıf bulunamadı"]))
                    return
                }
                
                // Mevcut öğrenci listesini al ve güncelle
                var currentStudents = document.data()?["students"] as? [String] ?? []
                if !currentStudents.contains(student.id) {
                    currentStudents.append(student.id)
                    
                    classRef.updateData([
                        "students": currentStudents
                    ]) { error in
                        if let error = error {
                            print("Öğrenci ekleme hatası: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("Öğrenci başarıyla eklendi")
                            completion(nil)
                        }
                    }
                } else {
                    print("Öğrenci zaten sınıfta")
                    completion(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Öğrenci zaten bu sınıfta"]))
                }
            }
        }
    }
    func addClass(_ schoolClass: SchoolClass, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("classes").document(schoolClass.id).setData([
            "id": schoolClass.id,
            "name": schoolClass.name,
            "teacherId": schoolClass.teacherId,
            "students": []
        ]) { error in
            if error == nil {
                self.classes.append(schoolClass)
            }
            completion(error)
        }
    }
    func deleteClass(classId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("classes").document(classId).delete { error in
            if error == nil {
                self.classes.removeAll { $0.id == classId }
            }
            completion(error)
        }
    }
    func fetchClassesForTeacher(teacherId: String, completion: @escaping ([SchoolClass]?, Error?) -> Void) {
        db.collection("classes").whereField("teacherId", isEqualTo: teacherId).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let classes = snapshot?.documents.compactMap { try? $0.data(as: SchoolClass.self) }
            self.classes = classes ?? []
            completion(classes, nil)
        }
    }
    func createClassForTeacher(teacherId: String, name: String, completion: @escaping (Error?) -> Void) {
        let newClass = SchoolClass(id: UUID().uuidString, name: name, teacherId: teacherId, students: [])
        addClass(newClass, completion: completion)
    }
    func fetchStudentsForClass(classId: String, completion: @escaping ([Student]?, Error?) -> Void) {
        print("Sınıf için öğrenciler getiriliyor: \(classId)")
        
        // Önce sınıfı al
        db.collection("classes").document(classId).getDocument { [weak self] document, error in
            if let error = error {
                print("Sınıf getirme hatası: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let document = document,
                  let classData = document.data(),
                  let studentIds = classData["students"] as? [String] else {
                print("Sınıf verisi bulunamadı veya öğrenci listesi yok")
                completion([], nil)
                return
            }
            
            print("Bulunan öğrenci ID'leri: \(studentIds)")
            
            if studentIds.isEmpty {
                completion([], nil)
                return
            }
            
            // Her bir öğrenci ID'si için children koleksiyonundan bilgileri al
            let dispatchGroup = DispatchGroup()
            var students: [Student] = []
            var fetchError: Error?
            
            for studentId in studentIds {
                dispatchGroup.enter()
                
                self?.db.collection("children").document(studentId).getDocument { document, error in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        print("Öğrenci getirme hatası: \(error.localizedDescription)")
                        fetchError = error
                        return
                    }
                    
                    if let document = document,
                       let data = document.data() {
                        let student = Student(
                            id: document.documentID,
                            name: data["name"] as? String ?? "",
                            age: data["age"] as? Int ?? 0,
                            studentId: data["studentId"] as? String ?? "",
                            birthDate: (data["birthDate"] as? Timestamp)?.dateValue()
                        )
                        students.append(student)
                        print("Öğrenci bulundu: \(student.name)")
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if let error = fetchError {
                    completion(nil, error)
                } else {
                    print("Toplam \(students.count) öğrenci bulundu")
                    completion(students, nil)
                }
            }
        }
    }
    func getStudentById(id: String, completion: @escaping (Student?) -> Void) {
        db.collection("students").document(id).getDocument { document, error in
            if let error = error {
                print("Öğrenci verisi alınırken hata oluştu: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let document = document, document.exists {
                do {
                    let student = try document.data(as: Student.self)
                    completion(student)
                } catch {
                    print("Öğrenci verisi çözümleme hatası: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    // MARK: - Öğrenci İsmi Getirme
    func getStudentName(by id: String, completion: @escaping (String?) -> Void) {
        db.collection("students").document(id).getDocument { document, error in
            if let error = error {
                print("Öğrenci ismi alınamadı: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let document = document, document.exists, let student = try? document.data(as: Student.self) {
                completion(student.name)
            } else {
                completion(nil)
            }
        }
    }
    // MARK: - 6 Haneli Öğrenci ID Üretimi
    func generateRandomChildId() -> String {
        return String(format: "%06d", Int.random(in: 0...999999))
    }
    // MARK: - Öğrenci Ekleme
    func addStudent(name: String, age: Int, completion: @escaping (Error?) -> Void) {
        let studentId = generateRandomChildId() // Otomatik 6 haneli ID oluşturuluyor
        let student = Student(
            id: studentId,
            name: name,
            age: age,
            studentId: studentId // studentId parametresini ekledik
        )

        // Öğrenciyi "students" koleksiyonuna kaydediyoruz
        do {
            try db.collection("students").document(studentId).setData(from: student) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    func signUp(name: String, phone: String, email: String, password: String, role: String, completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }

            guard let userId = authResult?.user.uid else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı ID'si bulunamadı"]))
                return
            }

            // Rol bilgisine göre Firestore'da kullanıcıyı kaydedelim
            let userRef = self.db.collection(role).document(userId)
            userRef.setData([
                "name": name,
                "phone": phone,
                "email": email,
                "role": role
            ]) { error in
                completion(error)
            }
        }
    }
    // MARK: - Giriş Yapma
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                completion(error)
                return
            }
            self?.fetchCurrentUserRole(completion: completion)
        }
    }
    func fetchCurrentUserRole(completion: @escaping (Error?) -> Void) {
        guard let userId = auth.currentUser?.uid else { return }

        // Öğretmen rolünü kontrol et
        db.collection("teachers").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                completion(error)
                return
            }

            if let document = document, document.exists {
                self?.currentUserRole = "teacher"
                self?.isAuthenticated = true
                completion(nil)
            } else {
                // Veli rolünü kontrol et
                self?.db.collection("parents").document(userId).getDocument { document, error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    if let document = document, document.exists {
                        self?.currentUserRole = "parent"
                        self?.isAuthenticated = true
                        completion(nil)
                    } else {
                        completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Rol bulunamadı"]))
                    }
                }
            }
        }
    }
    func signOut() {
        do {
            try auth.signOut()
            currentUserRole = nil
            isAuthenticated = false
            // Oturum bilgilerini temizle
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "userRole")
        } catch {
            print("Error signing out: \(error)")
        }
    }
    // MARK: - Homework Functions
    func updateHomeworkStatus(homeworkId: String, status: HomeworkStatus, completion: @escaping (Error?) -> Void) {
        db.collection("homework").document(homeworkId).updateData([
            "status": status.rawValue
        ]) { error in
            completion(error)
        }
    }
    // MARK: - Öğrenci Arama
    func checkStudentId(studentId: String, completion: @escaping (Student?, Error?) -> Void) {
        print("Aranan ID: \(studentId)")
        
        // Hem studentId hem de id alanlarında arama yap
        db.collection("children")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Arama hatası: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    print("Bulunan öğrenci verisi: \(data)")
                    
                    let student = Student(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        age: data["age"] as? Int ?? 0,
                        studentId: data["studentId"] as? String ?? "",
                        birthDate: (data["birthDate"] as? Timestamp)?.dateValue()
                    )
                    print("Oluşturulan student objesi: \(student)")
                    completion(student, nil)
                } else {
                    // studentId bulunamadıysa, id alanında ara
                    self?.db.collection("children")
                        .whereField("id", isEqualTo: studentId)
                        .getDocuments { snapshot, error in
                            if let document = snapshot?.documents.first {
                                let data = document.data()
                                let student = Student(
                                    id: document.documentID,
                                    name: data["name"] as? String ?? "",
                                    age: data["age"] as? Int ?? 0,
                                    studentId: data["studentId"] as? String ?? "",
                                    birthDate: (data["birthDate"] as? Timestamp)?.dateValue()
                                )
                                completion(student, nil)
                            } else {
                                print("Öğrenci bulunamadı - Aranan ID: \(studentId)")
                                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Öğrenci bulunamadı"]))
                            }
                        }
                }
            }
    }
    // MARK: - Öğretmen İşlemleri
    func fetchTeacherName(completion: @escaping (String) -> Void) {
        guard let teacherId = auth.currentUser?.uid else {
            completion("Öğretmen")
            return
        }
        
        db.collection("teachers").document(teacherId).getDocument { document, error in
            if let document = document,
               let data = document.data(),
               let name = data["name"] as? String {
                completion(name)
            } else {
                completion("Öğretmen")
            }
        }
    }
    func saveGameStats(
        studentId: String,
        correctMatches: Int,
        wrongMatches: Int,
        score: Int,
        fruits: [FruitMatchResult],
        playTime: TimeInterval,
        dailyPlayTime: TimeInterval,
        gameCompleted: Bool
    ) {
        guard let userId = auth.currentUser?.uid else { return }
        
        let gameStatsRef = Firestore.firestore().collection("gameStats")
        let today = Date()
        
        // Önce mevcut belgeyi kontrol et
        gameStatsRef
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let lastPlayDate = (data["lastPlayDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Gün kontrolü
                    let calendar = Calendar.current
                    let currentDay = calendar.startOfDay(for: today)
                    let lastDay = calendar.startOfDay(for: lastPlayDate)
                    
                    let updatedDailyTime = currentDay == lastDay ? dailyPlayTime : playTime
                    
                    // Belgeyi güncelle
                    document.reference.updateData([
                        "correctMatches": correctMatches,
                        "wrongMatches": wrongMatches,
                        "score": score,
                        "fruits": fruits.map { fruit in
                            [
                                "fruitName": fruit.fruitName,
                                "isCorrect": fruit.isCorrect,
                                "attemptCount": fruit.attemptCount
                            ]
                        },
                        "playTime": playTime,
                        "dailyPlayTime": updatedDailyTime,
                        "gameCompleted": gameCompleted,
                        "lastPlayDate": Timestamp(date: today)
                    ])
                } else {
                    // Yeni belge oluştur
                    let newData: [String: Any] = [
                        "studentId": studentId,
                        "parentId": userId,
                        "correctMatches": correctMatches,
                        "wrongMatches": wrongMatches,
                        "score": score,
                        "fruits": fruits.map { fruit in
                            [
                                "fruitName": fruit.fruitName,
                                "isCorrect": fruit.isCorrect,
                                "attemptCount": fruit.attemptCount
                            ]
                        },
                        "playTime": playTime,
                        "dailyPlayTime": playTime,
                        "gameCompleted": gameCompleted,
                        "lastPlayDate": Timestamp(date: today)
                    ]
                    
                    gameStatsRef.addDocument(data: newData)
                }
            }
    }
    func fetchFirstChild(completion: @escaping (Student?) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(nil)
            return
        }
        
        Firestore.firestore().collection("children")
            .whereField("parentId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let student = Student(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        age: data["age"] as? Int ?? 0,
                        studentId: data["studentId"] as? String ?? "",
                        birthDate: (data["birthDate"] as? Timestamp)?.dateValue(),
                        isPremium: data["isPremium"] as? Bool ?? false
                    )
                    completion(student)
                } else {
                    completion(nil)
                }
            }
    }
    func getDailyPlayTime(for studentId: String, completion: @escaping (TimeInterval) -> Void) {
        let db = Firestore.firestore()
        let gameStatsRef = db.collection("gameStats")
        
        gameStatsRef
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let lastPlayDate = (data["lastPlayDate"] as? Timestamp)?.dateValue() ?? Date()
                    let dailyPlayTime = data["dailyPlayTime"] as? Double ?? 0
                    
                    // Gün kontrolü
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let lastDate = calendar.startOfDay(for: lastPlayDate)
                    
                    if today != lastDate {
                        // Yeni gün başlamış, süreyi sıfırla
                        document.reference.updateData([
                            "dailyPlayTime": 0,
                            "lastPlayDate": Timestamp(date: Date())
                        ])
                        completion(0)
                    } else {
                        // Aynı gün, mevcut süreyi döndür
                        completion(dailyPlayTime)
                    }
                } else {
                    completion(0)
                }
            }
    }
    func updateStreak(for studentId: String, completion: @escaping (Int) -> Void) {
        guard let userId = auth.currentUser?.uid else { return }
        
        let gameStatsRef = Firestore.firestore().collection("gameStats")
        
        // Önce mevcut belgeyi kontrol et
        gameStatsRef
            .whereField("studentId", isEqualTo: studentId)
            .whereField("parentId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    let lastStreakDate = (data["lastStreakDate"] as? Timestamp)?.dateValue() ?? Date()
                    let currentStreak = data["streak"] as? Int ?? 0
                    
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    let lastDate = calendar.startOfDay(for: lastStreakDate)
                    
                    let daysDifference = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
                    
                    var newStreak = currentStreak
                    
                    if daysDifference == 1 {
                        // Ardışık gün - seriyi artır
                        newStreak += 1
                    } else if daysDifference > 1 {
                        // Seri bozuldu - sıfırla
                        newStreak = 1
                    } else if daysDifference == 0 {
                        // Aynı gün - seriyi koru
                        newStreak = currentStreak
                    }
                    
                    // Streak'i güncelle
                    document.reference.updateData([
                        "streak": newStreak,
                        "lastStreakDate": Timestamp(date: Date())
                    ])
                    
                    completion(newStreak)
                } else {
                    // İlk kez oynuyor - yeni belge oluştur
                    let newData: [String: Any] = [
                        "parentId": userId,
                        "studentId": studentId,
                        "streak": 1,
                        "lastStreakDate": Timestamp(date: Date()),
                        "correctMatches": 0,
                        "wrongMatches": 0,
                        "score": 0,
                        "playTime": 0,
                        "dailyPlayTime": 0,
                        "gameCompleted": false,
                        "fruits": []
                    ]
                    
                    gameStatsRef.addDocument(data: newData)
                    completion(1)
                }
            }
    }
    // MARK: - Ödev ve Bildirim İşlemleri
    func sendHomeworkNotification(homework: Homework, parentId: String) async {
        print("Creating notification for homework: \(homework.id) to parent: \(parentId)")
        
        let notification = Notification(
            id: UUID().uuidString,
            parentId: parentId,
            title: "Yeni Ödev",
            message: "'\(homework.title)' başlıklı yeni bir ödev gönderildi.",
            date: Date(),
            isRead: false,
            homeworkId: homework.id,
            homework: homework,
            type: .homework
        )
        
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                do {
                    try db.collection("notifications")
                        .document()
                        .setData(from: notification) { error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            print("Homework notification sent successfully")
        } catch {
            print("Error sending homework notification: \(error)")
        }
    }
    
    func fetchTeacherHomeworks(teacherId: String) async {
        do {
            let snapshot = try await db.collection("homework")
                .whereField("teacherId", isEqualTo: teacherId)
                .order(by: "assignedDate", descending: true)
                .getDocuments()
            
            let homeworks = snapshot.documents.compactMap { document -> Homework? in
                try? document.data(as: Homework.self)
            }
            
            // Her ödev için bildirim oluştur
            for homework in homeworks {
                await sendHomeworkNotification(
                    homework: homework,
                    parentId: homework.studentId
                )
            }
            
        } catch {
            print("Error fetching homeworks: \(error)")
        }
    }
    
    func fetchNotifications(for userId: String) async throws -> [Notification] {
        let notificationsSnapshot = try await db.collection("notifications")
            .whereField("parentId", isEqualTo: userId)
            .getDocuments()
        
        var notifications: [Notification] = []
        
        for document in notificationsSnapshot.documents {
            do {
                var notification = try document.data(as: Notification.self)
                
                if notification.type == .homework,
                   let homeworkId = notification.homeworkId {
                    if let homework = try await fetchHomeworkDetails(homeworkId: homeworkId) {
                        notification.homework = homework
                    }
                }
                notifications.append(notification)
            } catch {
                print("Error decoding notification: \(error)")
            }
        }
        
        return notifications.sorted { $0.date > $1.date }
    }
    func fetchHomeworkDetails(homeworkId: String) async throws -> Homework? {
        let document = try await db.collection("homework")
            .document(homeworkId)
            .getDocument()
        
        return try document.data(as: Homework.self)
    }
    // Hedef süreyi kaydetmek için yeni fonksiyon
    func saveDailyTarget(minutes: TimeInterval) {
        guard let userId = auth.currentUser?.uid else { return }
        
        db.collection("parents")
            .document(userId)
            .updateData([
                "dailyTarget": minutes
            ])
    }
    // Hedef süreyi getirmek için yeni fonksiyon
    func fetchDailyTarget(completion: @escaping (TimeInterval) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(30 * 60) // varsayılan değer
            return
        }
        
        db.collection("parents")
            .document(userId)
            .getDocument { document, error in
                if let data = document?.data(),
                   let target = data["dailyTarget"] as? TimeInterval {
                    completion(target)
                } else {
                    completion(30 * 60) // varsayılan değer
                }
            }
    }
    func updateDailyPlayTime(for studentId: String, additionalTime: TimeInterval) {
        let db = Firestore.firestore()
        let studentRef = db.collection("children").document(studentId)
        
        studentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching student: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else { 
                print("No student data found")
                return 
            }
            
            // Mevcut günlük süreyi al
            let currentDailyTime = data["dailyPlayTime"] as? TimeInterval ?? 0
            
            // Yeni süreyi hesapla
            let newDailyTime = currentDailyTime + additionalTime
            
            print("Updating daily play time: Current(\(Int(currentDailyTime/60)))min + New(\(Int(additionalTime/60)))min = Total(\(Int(newDailyTime/60)))min")
            
            // Firestore'u güncelle
            studentRef.updateData([
                "dailyPlayTime": newDailyTime,
                "lastPlayDate": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("Error updating daily play time: \(error)")
                } else {
                    print("Daily play time updated successfully")
                    // Güncelleme başarılı olduğunda bildirim gönder
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DailyPlayTimeUpdated"),
                        object: nil,
                        userInfo: ["dailyPlayTime": newDailyTime]
                    )
                }
            }
        }
    }
    func fetchStreak(for studentId: String, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        let studentRef = db.collection("children").document(studentId)
        
        studentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching streak: \(error)")
                completion(0)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No student data found")
                completion(0)
                return
            }
            
            // Streak'i al veya varsayılan olarak 0 döndür
            let streak = data["streak"] as? Int ?? 0
            
            // Son oyun tarihini kontrol et
            if let lastPlayTimestamp = data["lastPlayDate"] as? Timestamp {
                let lastPlayDate = lastPlayTimestamp.dateValue()
                let calendar = Calendar.current
                
                // Eğer son oyun bugün değilse streak'i sıfırla
                if !calendar.isDateInToday(lastPlayDate) {
                    studentRef.updateData([
                        "streak": 0
                    ]) { error in
                        if let error = error {
                            print("Error resetting streak: \(error)")
                        }
                    }
                    completion(0)
                } else {
                    completion(streak)
                }
            } else {
                completion(streak)
            }
        }
    }
    
    // Streak'i güncelle
    func updateStreak(for studentId: String) {
        let db = Firestore.firestore()
        let studentRef = db.collection("children").document(studentId)
        
        studentRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching student for streak update: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let currentStreak = data["streak"] as? Int ?? 0
            let lastPlayTimestamp = data["lastPlayDate"] as? Timestamp
            let calendar = Calendar.current
            
            if let lastPlayDate = lastPlayTimestamp?.dateValue() {
                // Eğer son oyun dünse streak'i artır
                if calendar.isDateInYesterday(lastPlayDate) {
                    studentRef.updateData([
                        "streak": currentStreak + 1,
                        "lastPlayDate": Timestamp(date: Date())
                    ])
                }
                // Eğer son oyun bugün değilse ve dün de değilse streak'i 1'e ayarla
                else if !calendar.isDateInToday(lastPlayDate) {
                    studentRef.updateData([
                        "streak": 1,
                        "lastPlayDate": Timestamp(date: Date())
                    ])
                }
            } else {
                // Hiç oyun oynamamışsa streak'i 1'e ayarla
                studentRef.updateData([
                    "streak": 1,
                    "lastPlayDate": Timestamp(date: Date())
                ])
            }
        }
    }
}
