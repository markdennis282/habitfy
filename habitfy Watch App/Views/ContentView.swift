
import SwiftUI

struct ContentView: View {
    @State private var isSignedIn = false
    @State private var currentUserID: String? = nil //store user id
    @State private var today = Date()
    @StateObject private var store: HabitStore // habit data

    init() {
        let savedUserID = UserDefaults.standard.string(forKey: "userID") ?? ""
        _store = StateObject(wrappedValue: HabitStore(userID: savedUserID))
        _isSignedIn = State(initialValue: !savedUserID.isEmpty)
        _currentUserID = State(initialValue: savedUserID)
    }

    var body: some View {
        Group {
            if !isSignedIn {//show sign in if not signed in
                SignInView(isSignedIn: $isSignedIn, currentUserID: $currentUserID)
            } else {
                mainHabitView
            }
        }
        .onChange(of: isSignedIn) { newValue in
            if newValue, let userID = currentUserID {
                store.updateUserID(userID)//get data of signed in user
            }
        }
    }
    
    var mainHabitView: some View {
        NavigationView {
            List {
                let completionFraction = calculateCompletionFraction()
                let allComplete = completionFraction == 1.0
                
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
                .listRowBackground(
                    allComplete
                    ? Color.green.opacity(0.2) //habits turn green when they are completed
                    : Color.gray.opacity(0.2)
                )
                
                let sortedHabits = sortHabits(store.habits)
                
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
                                
                                HStack(spacing: 8) {
                                    Text("🔥 \(habit.streak) \(habit.streak == 1 ? "day" : "days")")
                                    
                                    if let reminderTime = habit.reminderTime {
                                        Text("\(timeFormatter.string(from: reminderTime))")
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {//swipe delete habit
                        Button(role: .destructive) {
                            store.removeHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {//swipe undo completion
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
                

            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    NavigationLink(destination: MenuView(store: store,
                                                        isSignedIn: $isSignedIn,
                                                        currentUserID: $currentUserID)) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }

    //sort habits by reminder time
    private func sortHabits(_ habits: [Habit]) -> [Habit] {
        habits.sorted { a, b in
            let completedA = isHabitCompletedToday(a)
            let completedB = isHabitCompletedToday(b)
            
            if completedA == completedB {
                return (a.reminderTime ?? Date.distantFuture) < (b.reminderTime ?? Date.distantFuture)
            } else {
                return !completedA
            }
        }
    }
    // calcs completed habits for progress
    private func calculateCompletionFraction() -> Double {
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0.0 }
        
        let completedHabits = store.habits.filter(isHabitCompletedToday).count
        return Double(completedHabits) / Double(totalHabits)
    }
    //checks if habit has been completed
    private func isHabitCompletedToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains {
            calendar.isDateInToday($0)
        }
    }
//mark habit as completed and update streak
    private func completeHabit(_ habit: Habit) {
        var updatedHabit = habit
        let now = Date()
        
        updatedHabit.completionDates.append(now)
        
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

        store.updateHabit(updatedHabit)
    }
    
    private func checkForDayChange() {
        let calendar = Calendar.current
        if !calendar.isDate(today, inSameDayAs: Date()) {
            today = Date()
        }
    }

    private func undoCompletion(_ habit: Habit) {
        var updated = habit
        let calendar = Calendar.current
        
        if let index = updated.completionDates.firstIndex(where: {
            calendar.isDateInToday($0)
        }) {
            updated.completionDates.remove(at: index)
            
            updated.streak = recalcStreak(for: updated)
            
            store.updateHabit(updated)
        }
    }

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func recalcStreak(for habit: Habit) -> Int {
        let sortedDates = habit.completionDates.sorted()
        guard !sortedDates.isEmpty else { return 0 }

        var streak = 1
        var currentStreak = 1
        
        let calendar = Calendar.current
        for i in 1..<sortedDates.count {
            let prev = sortedDates[i - 1]
            let curr = sortedDates[i]
            
            if let dayAfterPrev = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(dayAfterPrev, inSameDayAs: curr) {
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return streak
    }
}
