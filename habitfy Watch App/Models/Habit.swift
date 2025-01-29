//
//  Habit.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    let name: String
    let reminderTime: Date?
    var completionDates: [Date]
    var streak: Int
    
    init(name: String, reminderTime: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.reminderTime = reminderTime
        self.completionDates = []
        self.streak = 0
    }
}
