//
//  Student.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//

import SwiftUI

// MARK: - Data Models
struct Student: Identifiable, Codable {
    var id: String
    var name: String
    var age: Int

}

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
}
