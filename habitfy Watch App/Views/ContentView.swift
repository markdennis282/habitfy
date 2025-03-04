//
//  ContentView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
import SwiftUI

struct ContentView: View {
    @State private var isSignedIn = false
    @State private var currentUserID: String? = nil
    @State private var today = Date()
    @StateObject private var store: HabitStore

    init() {
        let savedUserID = UserDefaults.standard.string(forKey: "userID") ?? ""
        _store = StateObject(wrappedValue: HabitStore(userID: savedUserID)) // ✅ Ensures a valid userID
        _isSignedIn = State(initialValue: !savedUserID.isEmpty)
        _currentUserID = State(initialValue: savedUserID)
    }

    var body: some View {
        Group {
            if !isSignedIn {
                SignInView(isSignedIn: $isSignedIn, currentUserID: $currentUserID)
            } else {
                mainHabitView
            }
        }
        .onChange(of: isSignedIn) { newValue in
            if newValue, let userID = currentUserID {
                store.updateUserID(userID)  // ✅ Ensures HabitStore has a userID after sign-in
            }
        }
    }
    
    var mainHabitView: some View {
        NavigationView {
            List {
                let completionFraction = calculateCompletionFraction()
                let allComplete = completionFraction == 1.0
                
                // "Today" row
                HStack {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: completionFraction,
                        lineWidth: 6,
                        progressColor: .blue,
                        backgroundColor: .gray.opacity(0.2)
                    )
                    .frame(width: 30, height: 30)
                }
                .padding(.vertical, 8)
                // Match habit background colors:
                .listRowBackground(
                    allComplete
                    ? Color.green.opacity(0.2)
                    : Color.gray.opacity(0.2)
                )
                
                // 1) Sort habits so incomplete appear first, completed last
                let sortedHabits = sortHabits(store.habits)
                
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
                                // Habit name
                                Text(habit.name)
                                    .foregroundColor(
                                        isHabitCompletedToday(habit) ? .gray : .primary
                                    )
                                
                                // Streak + Reminder on the same row
                                HStack(spacing: 8) {
                                    Text("🔥 \(habit.streak) \(habit.streak == 1 ? "day" : "days")")
                                    
                                    if let reminderTime = habit.reminderTime {
                                        Text("⏰ \(timeFormatter.string(from: reminderTime))")
                                    }
                                }
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
                    // Swipe Left: Delete Habit
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.removeHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    // Swipe Right: Undo Today's Completion
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
                
                // 3) Add Habit Section
//                Section {
//                    NavigationLink(destination: AddHabitView(store: store)) {
//                        VStack {
//                            Image(systemName: "plus.circle.fill")
//                                .font(.title2)
//                            Text("Add Habit")
//                                .font(.caption)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 44)
//                        .contentShape(Rectangle())
//                    }
//                    .buttonStyle(.plain)
//                }
//                .listRowBackground(Color.blue.opacity(0.2))
                
                // 4) Leaderboard Section
//                Section {
//                    NavigationLink(destination: LeaderboardView(store: store)) {
//                        VStack {
//                            Image(systemName: "person.3.sequence.fill")
//                                .font(.title2)
//                            Text("Leaderboard")
//                                .font(.caption)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 44)
//                        .contentShape(Rectangle())
//                    }
//                    .buttonStyle(.plain)
//                }
//                .listRowBackground(Color.orange.opacity(0.2))

                // 5) Analytics Section
//                Section {
//                    NavigationLink(destination: AnalyticsView(store: store)) {
//                        VStack {
//                            Image(systemName: "chart.bar.xaxis")
//                                .font(.title2)
//                            Text("Analytics")
//                                .font(.caption)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 44)
//                        .contentShape(Rectangle())
//                    }
//                    .buttonStyle(.plain)
//                }
//                .listRowBackground(Color.purple.opacity(0.2))
            }
            .navigationTitle("Today")
            .toolbar {
                // Put hamburger button on the top-left in watchOS
                ToolbarItem(placement: .cancellationAction) {
                    // Pass the sign-in state as BINDINGS to MenuView
                    NavigationLink(destination: MenuView(store: store,
                                                        isSignedIn: $isSignedIn,
                                                        currentUserID: $currentUserID)) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods
    
    private func sortHabits(_ habits: [Habit]) -> [Habit] {
        habits.sorted { a, b in
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
    }
    
    private func calculateCompletionFraction() -> Double {
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0.0 }
        
        let completedHabits = store.habits.filter(isHabitCompletedToday).count
        return Double(completedHabits) / Double(totalHabits)
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
        
        // 1. Add today's completion date
        updatedHabit.completionDates.append(now)
        
        // 2. Streak logic
        let calendar = Calendar.current
        if let lastCompletion = habit.completionDates.last {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
               calendar.isDate(lastCompletion, inSameDayAs: yesterday) {
                updatedHabit.streak += 1
            } else {
                updatedHabit.streak = 1
            }
        } else {
            updatedHabit.streak = 1
        }

        // 3. Persist the changes
        store.updateHabit(updatedHabit)
    }

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

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
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
