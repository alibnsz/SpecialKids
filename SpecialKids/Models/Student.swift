//
//  Student.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI
import FirebaseFirestore

struct Student: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var age: Int
    var studentId: String
    var birthDate: Date?
    var isPremium: Bool
    
    init(id: String = UUID().uuidString, name: String, age: Int, studentId: String, birthDate: Date? = nil, isPremium: Bool = false) {
        self.id = id
        self.name = name
        self.age = age
        self.studentId = studentId
        self.birthDate = birthDate
        self.isPremium = isPremium
    }
    
    static func == (lhs: Student, rhs: Student) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.age == rhs.age &&
        lhs.studentId == rhs.studentId &&
        lhs.birthDate == rhs.birthDate &&
        lhs.isPremium == rhs.isPremium
    }
}
