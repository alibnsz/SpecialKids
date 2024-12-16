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
    let name: String
    let age: Int
    let studentId: String
    var birthDate: Date?
}
