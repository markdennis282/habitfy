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
    
    // Date formatter for displaying the reminder time
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        let sortedHabits = store.habits.sorted {
            ($0.reminderTime ?? Date.distantFuture) < ($1.reminderTime ?? Date.distantFuture)
        }.filter { habit in
            // Filter out habits already completed today
            !isHabitCompletedToday(habit)
        }
        
        List(sortedHabits) { habit in
            Button(action: {
                completeHabit(habit)
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                    if let reminderTime = habit.reminderTime {
                        Text("Reminder: \(timeFormatter.string(from: reminderTime))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
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
            let calendar = Calendar.current
            if let dayBeforeNow = calendar.date(byAdding: .day, value: -1, to: now),
               calendar.isDate(lastCompletion, inSameDayAs: dayBeforeNow) {
                updatedHabit.streak += 1
            } else {
                updatedHabit.streak = 1
            }
        } else {
            updatedHabit.streak = 1
        }
        
        store.updateHabit(updatedHabit)
    }

    private func checkForDayChange() {
        let calendar = Calendar.current
        if !calendar.isDate(today, inSameDayAs: Date()) {
            today = Date()
        }
    }
}
