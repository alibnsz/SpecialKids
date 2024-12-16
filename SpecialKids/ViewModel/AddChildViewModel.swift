import Foundation
import FirebaseFirestore

class AddChildViewModel: ObservableObject {
    @Published var currentStep = 1
    
    // Temel Bilgiler
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var gender = ""
    @Published var hasDiagnosis = false
    @Published var diagnosisDetails = ""
    
    // İletişim Becerileri
    @Published var canCommunicateVerbally = ""
    @Published var usesAlternativeCommunication = false
    @Published var alternativeCommunicationDetails = ""
    
    // Sosyal Beceriler
    @Published var socialInteractionDifficulty = ""
    @Published var playsWithOthers = ""
    
    // Akademik Beceriler
    @Published var canRecognizeLetters = false
    @Published var canRecognizeNumbers = false
    @Published var canUnderstandStories = false
    @Published var canFollowInstructions = false
    
    // Günlük Yaşam Becerileri
    @Published var needsHelpEating = ""
    @Published var toiletIndependence = ""
    
    // Duyusal Hassasiyetler
    @Published var hasSoundSensitivity = false
    @Published var soundSensitivityDetails = ""
    @Published var hasTextureSensitivity = false
    @Published var textureSensitivityDetails = ""
    
    // İlgi Alanları
    @Published var interests = ""
    @Published var preferredToys = ""
    
    // Diğer adımlar için gerekli @Published değişkenler...
    @Published var studentId = ""
    @Published var showSuccessAlert = false
    @Published var navigateToParentView = false
    
    private func generateStudentId() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        let firstTwo = String((0..<2).map { _ in letters.randomElement()! })
        let lastFour = String((0..<4).map { _ in numbers.randomElement()! })
        
        return firstTwo + lastFour
    }
    
    func getCurrentTitle() -> String {
        switch currentStep {
        case 1: return "Temel Bilgiler"
        case 2: return "İletişim Becerileri"
        case 3: return "Sosyal Beceriler"
        case 4: return "Akademik ve Bilişsel Beceriler"
        case 5: return "Günlük Hayat Becerileri"
        case 6: return "Duyusal Hassasiyetler"
        case 7: return "İlgi Alanları ve Tercihler"
        default: return ""
        }
    }
    
    func nextStep() {
        if currentStep < 7 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    func saveChild() {
        let db = Firestore.firestore()
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let studentId = generateStudentId()
        self.studentId = studentId
        
        let childData: [String: Any] = [
            "name": name,
            "birthDate": birthDate,
            "gender": gender,
            "hasDiagnosis": hasDiagnosis,
            "diagnosisDetails": diagnosisDetails,
            "studentId": studentId,
            "parentId": userId,
            "createdAt": Timestamp(),
            "canCommunicateVerbally": canCommunicateVerbally,
            "usesAlternativeCommunication": usesAlternativeCommunication,
            "alternativeCommunicationDetails": alternativeCommunicationDetails,
            "socialInteractionDifficulty": socialInteractionDifficulty,
            "playsWithOthers": playsWithOthers,
            "canRecognizeLetters": canRecognizeLetters,
            "canRecognizeNumbers": canRecognizeNumbers,
            "canUnderstandStories": canUnderstandStories,
            "canFollowInstructions": canFollowInstructions,
            "needsHelpEating": needsHelpEating,
            "toiletIndependence": toiletIndependence,
            "hasSoundSensitivity": hasSoundSensitivity,
            "soundSensitivityDetails": soundSensitivityDetails,
            "hasTextureSensitivity": hasTextureSensitivity,
            "textureSensitivityDetails": textureSensitivityDetails,
            "interests": interests,
            "preferredToys": preferredToys
        ]
        
        db.collection("children").document(studentId).setData(childData) { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error adding child: \(error)")
                } else {
                    self.showSuccessAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.navigateToParentView = true
                    }
                }
            }
        }
    }
} 