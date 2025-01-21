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
}
