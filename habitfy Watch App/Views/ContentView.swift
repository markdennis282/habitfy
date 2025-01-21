//
//  ContentView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
import SwiftUI

struct ContentView: View {
    @StateObject var store = HabitStore()
    @State private var today = Date()

    var body: some View {
        NavigationView {
            List {
                // 1) Sort habits so incomplete appear first, completed appear last
                let sortedHabits = store.habits.sorted { a, b in
                    let completedA = isHabitCompletedToday(a)
                    let completedB = isHabitCompletedToday(b)
                    
                    if completedA == completedB {
                        // If both have the same completion status,
                        // sort by their reminder times (earlier first).
                        return a.reminderTime < b.reminderTime
                    } else {
                        // Put incomplete habits (completed == false) first
                        return !completedA
                    }
                }
                
                // 2) Display each habit
                ForEach(sortedHabits) { habit in
                    Button {
                        if !isHabitCompletedToday(habit) {
                            completeHabit(habit)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name)
                                    .foregroundColor(
                                        isHabitCompletedToday(habit) ? .gray : .primary
                                    )
                                Text("🔥 \(habit.streak) \(habit.streak == 1 ? "day" : "days")")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if isHabitCompletedToday(habit) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(
                        isHabitCompletedToday(habit)
                        ? Color.green.opacity(0.2)
                        : Color.gray.opacity(0.2)
                    )
                    // SWIPE ACTIONS - Only available on watchOS 9+
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            // Remove the habit from the store
                            store.removeHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                
                // 5) Add Habit Section
                Section {
                    NavigationLink(destination: AddHabitView(store: store)) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Habit")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.blue.opacity(0.2)) // Optional: Add background color for distinction

                // 6) Analytics Section
                Section {
                    NavigationLink(destination: AnalyticsView(store: store)) {
                        VStack {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title2)
                            Text("Analytics")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.purple.opacity(0.2)) // Optional: Add background color for distinction
            }
            .navigationTitle("Today")
            .onAppear {
                checkForDayChange()
            }
        }
    }

    // MARK: - Helper Methods
    
    /// Returns true if the habit is completed today
    private func isHabitCompletedToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains { date in
            calendar.isDateInToday(date)
        }
    }

    /// Mark the habit as completed, update streak, and save
    private func completeHabit(_ habit: Habit) {
        var updatedHabit = habit
        let now = Date()
        
        // 1. Add today's completion date
        updatedHabit.completionDates.append(now)
        
        // 2. Streak logic
        let calendar = Calendar.current
        if let lastCompletion = habit.completionDates.last {
            // If the last completion was exactly yesterday, increment
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
               calendar.isDate(lastCompletion, inSameDayAs: yesterday) {
                updatedHabit.streak += 1
            } else {
                // Otherwise, reset to 1
                updatedHabit.streak = 1
            }
        } else {
            // First-ever completion
            updatedHabit.streak = 1
        }

        // 3. Persist the changes
        store.updateHabit(updatedHabit)
    }

    /// If it’s a new day, do any day-change logic here
    private func checkForDayChange() {
        let calendar = Calendar.current
        if !calendar.isDate(today, inSameDayAs: Date()) {
            today = Date()
            // e.g., do other day-change checks if needed
        }
    }
}
