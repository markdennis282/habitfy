//
//  Friend.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 29/01/2025.
//

import Foundation

struct Friend: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var bestStreak: Int
    var totalCompletionsLast7Days: Int

    init(name: String, bestStreak: Int = 0, totalCompletionsLast7Days: Int = 0) {
        self.id = UUID()
        self.name = name
        self.bestStreak = bestStreak
        self.totalCompletionsLast7Days = totalCompletionsLast7Days
    }

    // Add Equatable conformance
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        lhs.id == rhs.id
    }
}
