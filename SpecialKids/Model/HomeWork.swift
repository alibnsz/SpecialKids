//
//  HomeWork.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 23.11.2024.
//
import SwiftUI

// Eğer aynı veri yapısına sahipse:
struct Homework: Identifiable {
    var id: String
    var title: String
    var description: String
    var dueDate: Date
    var studentId: String
}

typealias Assignment = Homework // Aynı yapıyı kullandığınızı varsayalım
