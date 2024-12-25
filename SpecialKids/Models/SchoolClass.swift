import Foundation
import FirebaseFirestore

struct SchoolClass: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let teacherId: String
    let students: [String]
    
    init(id: String = UUID().uuidString, name: String, teacherId: String, students: [String] = []) {
        self.id = id
        self.name = name
        self.teacherId = teacherId
        self.students = students
    }
    
    static func == (lhs: SchoolClass, rhs: SchoolClass) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.teacherId == rhs.teacherId &&
               lhs.students == rhs.students
    }
} 