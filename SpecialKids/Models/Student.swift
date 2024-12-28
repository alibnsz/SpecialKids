//
//  Student.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI
import FirebaseFirestore

struct Student: Identifiable, Codable {
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
}
