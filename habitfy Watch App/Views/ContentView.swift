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
                HStack {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: calculateCompletionFraction(),
                        lineWidth: 6,
                        progressColor: .blue,
                        backgroundColor: .gray.opacity(0.2)
                    )
                    .frame(width: 30, height: 30)
                }
                .padding(.vertical, 8)
                
                // 1) Sort habits so incomplete appear first, completed last
                let sortedHabits = store.habits.sorted { a, b in
                    let completedA = isHabitCompletedToday(a)
                    let completedB = isHabitCompletedToday(b)
                    
                    if completedA == completedB {
                        // If both have the same completion status,
                        // sort by their reminder times (earlier first).
                        return (a.reminderTime ?? Date.distantFuture) < (b.reminderTime ?? Date.distantFuture)
                    } else {
                        // Put incomplete habits first
                        return !completedA
                    }
                }
                
                // 2) Display each habit
                ForEach(sortedHabits) { habit in
                    Button {
                        // Mark incomplete habit as complete
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
                    // 1) Swipe Left: Delete Habit
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.removeHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    // 2) Swipe Right: Undo Today's Completion
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        if isHabitCompletedToday(habit) {
                            Button {
                                undoCompletion(habit)
                            } label: {
                                Label("Undo", systemImage: "arrow.uturn.left.circle")
                            }
                            .tint(.blue)
                        }
                    }
                }
                
                // 5) Add Habit Section (KEEP in List)
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
                .listRowBackground(Color.blue.opacity(0.2))
                //leaderboard
                Section {
                    NavigationLink(destination: LeaderboardView(store: store)) {
                        VStack {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.title2)
                            Text("Leaderboard")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.orange.opacity(0.2))

                
                // 6) Analytics Section (KEEP in List)
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
                .listRowBackground(Color.purple.opacity(0.2))
            }
            .navigationTitle("Today")
            .toolbar {
                // Put hamburger button on the top-left in watchOS
                ToolbarItem(placement: .cancellationAction) {
                    NavigationLink(destination: MenuView(store: store)) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            
        }
    }


    //  Helper Methods
    

    private func calculateCompletionFraction() -> Double {
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0.0 }
        
        let completedHabits = store.habits.filter(isHabitCompletedToday).count
        return Double(completedHabits) / Double(totalHabits)
    }
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
    private func undoCompletion(_ habit: Habit) {
        var updated = habit
        let calendar = Calendar.current
        
        // 1) Find any completion date that occurred today
        if let index = updated.completionDates.firstIndex(where: {
            calendar.isDateInToday($0)
        }) {
            // Remove that date
            updated.completionDates.remove(at: index)
            
            // Recalculate the streak from scratch or adjust it
            updated.streak = recalcStreak(for: updated)
            
            // Persist changes
            store.updateHabit(updated)
        }
    }

    /// Example "recalc" method that rebuilds the streak based on consecutive day completions
    private func recalcStreak(for habit: Habit) -> Int {
        // Sort completionDates so newest is last
        let sortedDates = habit.completionDates.sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var streak = 1
        var currentStreak = 1
        
        let calendar = Calendar.current
        for i in 1..<sortedDates.count {
            // Check if this date is exactly 1 day after the previous date
            let prev = sortedDates[i - 1]
            let curr = sortedDates[i]
            
            if let dayAfterPrev = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(dayAfterPrev, inSameDayAs: curr) {
                // Consecutive day => increment
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                // Non-consecutive day => reset
                currentStreak = 1
            }
        }
        
        return streak
    }


}

