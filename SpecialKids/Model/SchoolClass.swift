import Foundation
import FirebaseFirestore

struct SchoolClass: Identifiable, Codable {
    var id: String
    var name: String
    var teacherId: String
    var students: [String]
    
    init(id: String = UUID().uuidString, name: String, teacherId: String, students: [String] = []) {
        self.id = id
        self.name = name
        self.teacherId = teacherId
        self.students = students
    }
    
    static func == (lhs: SchoolClass, rhs: SchoolClass) -> Bool {
        return lhs.id == rhs.id
    }
} 