//
//  HabitStore.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import SwiftUI
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var friends: [Friend] = [
        // Add a few sample friends for testing
        Friend(name: "Alice", bestStreak: 5, totalCompletionsLast7Days: 20),
        Friend(name: "Bob", bestStreak: 3, totalCompletionsLast7Days: 15),
        Friend(name: "Carol", bestStreak: 8, totalCompletionsLast7Days: 29)
    ]

    private let storeKey = "habitsKey"

    init() {
        loadHabits()
    }

    func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }

    func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: storeKey)
        }
    }

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }

    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }

    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    func addFriend(_ friend: Friend) {
        friends.append(friend)
        // If you want to persist friend data in UserDefaults,
        // you'll need a separate key and JSON encoding,
        // similar to how you do it for `habits`.
    }
    
    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
    }
}
