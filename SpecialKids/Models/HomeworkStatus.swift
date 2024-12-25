//
//  HomeworkStatus.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 16.12.2024.
//


import Foundation
import FirebaseFirestore

enum HomeworkStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case late = "late"
}

struct Homework: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let dueDate: Date
    let studentId: String
    let teacherId: String?
    let status: HomeworkStatus
    let assignedDate: Date
    let className: String?
    let studentName: String?
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         dueDate: Date,
         studentId: String,
         teacherId: String? = nil,
         status: HomeworkStatus = .pending,
         assignedDate: Date = Date(),
         className: String? = nil,
         studentName: String? = nil) {
        
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.studentId = studentId
        self.teacherId = teacherId
        self.status = status
        self.assignedDate = assignedDate
        self.className = className
        self.studentName = studentName
    }
    
    // Ödev teslim tarihi geçmiş mi kontrolü
    var isLate: Bool {
        return Date() > dueDate && status == .pending
    }
    
    // Ödevin durumunu güncelleme
    func updateStatus(_ newStatus: HomeworkStatus) -> Homework {
        return Homework(id: id,
                       title: title,
                       description: description,
                       dueDate: dueDate,
                       studentId: studentId,
                       teacherId: teacherId,
                       status: newStatus,
                       assignedDate: assignedDate,
                       className: className,
                       studentName: studentName)
    }
    
    // Ödev teslim tarihine kalan süre
    var remainingTime: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: Date(), to: dueDate)
        
        if let days = components.day, let hours = components.hour {
            if days > 0 {
                return "\(days) gün \(hours) saat"
            } else if hours > 0 {
                return "\(hours) saat"
            } else {
                return "Süre doldu"
            }
        }
        return "Belirsiz"
    }
}

// Assignment ve Homework aynı yapıyı kullanacak
typealias Assignment = Homework