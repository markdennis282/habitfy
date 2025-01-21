//
//  Habit.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var reminderTime: Date   // Only one reminder per day
    var streak: Int          // Current streak
    var completionDates: [Date] // Store completion history for analytics

    init(name: String, reminderTime: Date) {
        self.id = UUID()
        self.name = name
        self.reminderTime = reminderTime
        self.streak = 0
        self.completionDates = []
    }
}
