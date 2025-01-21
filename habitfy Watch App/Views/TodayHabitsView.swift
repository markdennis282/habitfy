//
//  TodayHabitsView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
import SwiftUI
import Combine

struct TodayHabitsView: View {
    @ObservedObject var store: HabitStore
    @State private var today = Date()

    var body: some View {
        let sortedHabits = store.habits.sorted {
            $0.reminderTime < $1.reminderTime
        }.filter { habit in
            // Filter out habits already completed today
            !isHabitCompletedToday(habit)
        }
        
        List(sortedHabits) { habit in
            Button(action: {
                completeHabit(habit)
            }) {
                Text(habit.name)
            }
        }
        .navigationTitle("Today")
        .onAppear {
            checkForDayChange()
        }
    }

    private func isHabitCompletedToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains {
            calendar.isDateInToday($0)
        }
    }

    private func completeHabit(_ habit: Habit) {
        var updatedHabit = habit
        let now = Date()
        updatedHabit.completionDates.append(now)
        
        // Streak logic
        if let lastCompletion = habit.completionDates.last {
            // If last completion was "yesterday" or earlier, increment streak
            // Otherwise, if user missed a day, reset to 1
            let calendar = Calendar.current
            if let dayBeforeNow = calendar.date(byAdding: .day, value: -1, to: now),
               calendar.isDate(lastCompletion, inSameDayAs: dayBeforeNow) {
                updatedHabit.streak += 1
            } else {
                // If it wasn't yesterday, reset to 1
                updatedHabit.streak = 1
            }
        } else {
            // First ever completion
            updatedHabit.streak = 1
        }
        
        store.updateHabit(updatedHabit)
    }

    // Reset daily completions at midnight if needed
    private func checkForDayChange() {
        let calendar = Calendar.current
        if !calendar.isDate(today, inSameDayAs: Date()) {
            today = Date()
            // Additional logic to handle day change if needed
        }
    }
}
