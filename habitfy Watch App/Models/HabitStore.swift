//
//  HabitStore.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
//
//import SwiftUI
//import Combine
//
//class HabitStore: ObservableObject {
//    @Published var habits: [Habit] = []
//    @Published var friends: [Friend] = [
//        // Add a few sample friends for testing
//        Friend(name: "Alice", bestStreak: 5, totalCompletionsLast7Days: 20),
//        Friend(name: "Bob", bestStreak: 3, totalCompletionsLast7Days: 15),
//        Friend(name: "Carol", bestStreak: 8, totalCompletionsLast7Days: 29)
//    ]
//
//    private let storeKey = "habitsKey"
//
//    init() {
//        loadHabits()
//    }
//
//    func loadHabits() {
//        if let data = UserDefaults.standard.data(forKey: storeKey),
//           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
//            habits = decoded
//        }
//    }
//
//    func saveHabits() {
//        if let encoded = try? JSONEncoder().encode(habits) {
//            UserDefaults.standard.set(encoded, forKey: storeKey)
//        }
//    }
//
//    func addHabit(_ habit: Habit) {
//        habits.append(habit)
//        saveHabits()
//    }
//
//    func updateHabit(_ habit: Habit) {
//        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
//            habits[index] = habit
//            saveHabits()
//        }
//    }
//
//    func removeHabit(_ habit: Habit) {
//        habits.removeAll { $0.id == habit.id }
//        saveHabits()
//    }
//    func addFriend(_ friend: Friend) {
//        friends.append(friend)
//        // If you want to persist friend data in UserDefaults,
//        // you'll need a separate key and JSON encoding,
//        // similar to how you do it for `habits`.
//    }
//    
//    func removeFriend(_ friend: Friend) {
//        friends.removeAll { $0.id == friend.id }
//    }
//    func syncAnalytics() {
//            // Compute your analytics values
//            let bestStreak = habits.map { $0.streak }.max() ?? 0
//            let totalHabits = habits.count
//            let perfectDays = computePerfectDaysPast7Days()  // Your existing function or similar
//            let totalCompletions = computeTotalCompletionsPast7Days()  // Your existing function or similar
//            
//            // Retrieve the userID saved during sign-in
//            if let userID = UserDefaults.standard.string(forKey: "userID") {
//                syncAnalyticsToServer(userID: userID,
//                                      totalHabits: totalHabits,
//                                      longestStreak: bestStreak,
//                                      perfectDays: perfectDays,
//                                      totalCompletions: totalCompletions)
//            }
//        }
//    
//    func syncAnalyticsToServer(userID: String,
//                                   totalHabits: Int,
//                                   longestStreak: Int,
//                                   perfectDays: Int,
//                               totalCompletions: Int) {
//        let payload: [String: Any] = [
//            "user_id": userID,
//            "total_habits": totalHabits,
//            "longest_streak": longestStreak,
//            "perfect_days": perfectDays,
//            "total_completions": totalCompletions
//        ]
//        
//        guard let url = URL(string: "http://YOUR_SERVER_IP_OR_DOMAIN:5001/stats"),
//              let jsonData = try? JSONSerialization.data(withJSONObject: payload)
//        else {
//            print("❌ Invalid URL or JSON encoding error")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network error syncing stats: \(error.localizedDescription)")
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ No valid HTTP response syncing stats")
//                return
//            }
//            if httpResponse.statusCode == 200 {
//                print("✅ Stats synced successfully with the server.")
//            } else {
//                print("❌ Server error syncing stats: \(httpResponse.statusCode)")
//                if let data = data,
//                   let responseStr = String(data: data, encoding: .utf8) {
//                    print("Response body:", responseStr)
//                }
//            }
//        }.resume()
//    }
//    
//    
//}

//
//import SwiftUI
//import Combine
//
//class HabitStore: ObservableObject {
//    // When habits change, automatically save and sync analytics.
//    @Published var habits: [Habit] = [] {
//        didSet {
//            saveHabits()
//            syncAnalytics()
//        }
//    }
//    
//    @Published var friends: [Friend] = [
//        // Sample friends for testing
//        Friend(name: "Alice", bestStreak: 5, totalCompletionsLast7Days: 20),
//        Friend(name: "Bob", bestStreak: 3, totalCompletionsLast7Days: 15),
//        Friend(name: "Carol", bestStreak: 8, totalCompletionsLast7Days: 29)
//    ]
//    
//    private let storeKey = "habitsKey"
//    
//    init() {
//        loadHabits()
//    }
//    
//    // MARK: - Persistence
//    
//    func loadHabits() {
//        if let data = UserDefaults.standard.data(forKey: storeKey),
//           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
//            habits = decoded
//        }
//    }
//    
//    func saveHabits() {
//        if let encoded = try? JSONEncoder().encode(habits) {
//            UserDefaults.standard.set(encoded, forKey: storeKey)
//        }
//    }
//    
//    // MARK: - Habit CRUD Methods
//    
//    func addHabit(_ habit: Habit) {
//        habits.append(habit)
//        // didSet automatically calls saveHabits() and syncAnalytics()
//    }
//    
//    func updateHabit(_ habit: Habit) {
//        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
//            habits[index] = habit
//            // didSet automatically calls saveHabits() and syncAnalytics()
//        }
//    }
//    
//    func removeHabit(_ habit: Habit) {
//        habits.removeAll { $0.id == habit.id }
//        // didSet automatically calls saveHabits() and syncAnalytics()
//    }
//    
//    func addFriend(_ friend: Friend) {
//        friends.append(friend)
//        // Optionally persist friend data similarly.
//    }
//    
//    func removeFriend(_ friend: Friend) {
//        friends.removeAll { $0.id == friend.id }
//    }
//    
//    // MARK: - Analytics Computation and Sync
//    
//    /// Recalculates analytics based on the current habits and sends them to the backend.
//    func syncAnalytics() {
//        // Compute analytics values using your existing functions.
//        let bestStreak = habits.map { $0.streak }.max() ?? 0
//        let totalHabits = habits.count
//        let perfectDays = computePerfectDaysPast7Days()
//        let totalCompletions = computeTotalCompletionsPast7Days()
//        
//        // Retrieve the userID saved during sign-in.
//        if let userID = UserDefaults.standard.string(forKey: "userID") {
//            syncAnalyticsToServer(userID: userID,
//                                  totalHabits: totalHabits,
//                                  longestStreak: bestStreak,
//                                  perfectDays: perfectDays,
//                                  totalCompletions: totalCompletions)
//        }
//    }
//    
//    /// Computes the number of perfect days in the last 7 days.
//    private func computePerfectDaysPast7Days() -> Int {
//        let calendar = Calendar.current
//        let totalHabits = habits.count
//        guard totalHabits > 0 else { return 0 }
//        
//        var perfectCount = 0
//        for i in 0..<7 {
//            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
//                // A perfect day is when every habit is completed on that day.
//                let completedAll = habits.allSatisfy { habit in
//                    habit.completionDates.contains { calendar.isDate($0, inSameDayAs: day) }
//                }
//                if completedAll {
//                    perfectCount += 1
//                }
//            }
//        }
//        return perfectCount
//    }
//    
//    /// Computes total habit completions across all habits in the last 7 days.
//    private func computeTotalCompletionsPast7Days() -> Int {
//        let calendar = Calendar.current
//        var total = 0
//        for habit in habits {
//            let last7DaysCompletions = habit.completionDates.filter { date in
//                guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return false }
//                return date >= sevenDaysAgo
//            }
//            total += last7DaysCompletions.count
//        }
//        return total
//    }
//    
//    // MARK: - Network Sync
//    
//    /// Syncs the computed analytics to your Flask backend via the /stats endpoint.
//    func syncAnalyticsToServer(userID: String,
//                               totalHabits: Int,
//                               longestStreak: Int,
//                               perfectDays: Int,
//                               totalCompletions: Int) {
//        let payload: [String: Any] = [
//            "user_id": userID,
//            "total_habits": totalHabits,
//            "longest_streak": longestStreak,
//            "perfect_days": perfectDays,
//            "total_completions": totalCompletions
//        ]
//        
//        guard let url = URL(string: "http://127.0.0.1:5001/stats"),
//              let jsonData = try? JSONSerialization.data(withJSONObject: payload)
//        else {
//            print("❌ Invalid URL or JSON encoding error")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Network error syncing stats: \(error.localizedDescription)")
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("❌ No valid HTTP response syncing stats")
//                return
//            }
//            if httpResponse.statusCode == 200 {
//                print("✅ Stats synced successfully with the server.")
//            } else {
//                print("❌ Server error syncing stats: \(httpResponse.statusCode)")
//                if let data = data,
//                   let responseStr = String(data: data, encoding: .utf8) {
//                    print("Response body:", responseStr)
//                }
//            }
//        }.resume()
//    }
//}


import SwiftUI
import Combine

class HabitStore: ObservableObject {
    // When habits change, automatically save and sync analytics.
    @Published var habits: [Habit] = [] {
        didSet {
            print("habits didSet: count = \(habits.count)")
            saveHabits()
            syncAnalytics()
        }
    }
    
    @Published var friends: [Friend] = [
        // Sample friends for testing
        Friend(name: "Alice", bestStreak: 5, totalCompletionsLast7Days: 20),
        Friend(name: "Bob", bestStreak: 3, totalCompletionsLast7Days: 15),
        Friend(name: "Carol", bestStreak: 8, totalCompletionsLast7Days: 29)
    ]
    
    private let storeKey = "habitsKey"
    private var userID: String

    init(userID: String) {
        self.userID = userID
        loadHabits()
    }

    func updateUserID(_ newUserID: String) {
        guard newUserID != userID else { return } // Avoid unnecessary updates
        self.userID = newUserID
        syncAnalytics()  // ✅ Re-sync analytics after updating userID
    }
    
    // MARK: - Persistence
    
    func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
            print("Loaded \(habits.count) habits from UserDefaults")
        } else {
            print("No habits found in UserDefaults")
        }
    }
    
    func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: storeKey)
            print("Saved \(habits.count) habits to UserDefaults")
        } else {
            print("❌ Error encoding habits")
        }
    }
    
    // MARK: - Habit CRUD Methods
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        print("Added habit: \(habit.name), id: \(habit.id)")
        // didSet automatically calls saveHabits() and syncAnalytics()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            print("Updated habit: \(habit.name), id: \(habit.id)")
            // didSet automatically calls saveHabits() and syncAnalytics()
        } else {
            print("❌ Habit not found for update: \(habit.id)")
        }
    }
    
    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        print("Removed habit: \(habit.name), id: \(habit.id)")
        // didSet automatically calls saveHabits() and syncAnalytics()
    }
    
    func addFriend(_ friend: Friend) {
        friends.append(friend)
        print("Added friend: \(friend.name)")
        // Optionally persist friend data similarly.
    }
    
    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
        print("Removed friend: \(friend.name)")
    }
    
    // MARK: - Analytics Computation and Sync
    
    /// Recalculates analytics based on the current habits and sends them to the backend.
    func syncAnalytics() {
        let bestStreak = habits.map { $0.streak }.max() ?? 0
        let totalHabits = habits.count
        let perfectDays = computePerfectDaysPast7Days()
        let totalCompletions = computeTotalCompletionsPast7Days()
        
        print("Sync Analytics:")
        print(" - Total Habits: \(totalHabits)")
        print(" - Best Streak: \(bestStreak)")
        print(" - Perfect Days (last 7): \(perfectDays)")
        print(" - Total Completions (last 7): \(totalCompletions)")
        
        // Always re-read userID from UserDefaults.
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("No userID found in UserDefaults; skipping analytics sync.")
            return
        }
        
        syncAnalyticsToServer(userID: userID,
                              totalHabits: totalHabits,
                              longestStreak: bestStreak,
                              perfectDays: perfectDays,
                              totalCompletions: totalCompletions)
    }
    
    /// Computes the number of perfect days in the last 7 days.
    private func computePerfectDaysPast7Days() -> Int {
        let calendar = Calendar.current
        let totalHabits = habits.count
        guard totalHabits > 0 else { return 0 }
        
        var perfectCount = 0
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let completedAll = habits.allSatisfy { habit in
                    habit.completionDates.contains { calendar.isDate($0, inSameDayAs: day) }
                }
                if completedAll {
                    perfectCount += 1
                }
            }
        }
        return perfectCount
    }
    
    /// Computes total habit completions across all habits in the last 7 days.
    private func computeTotalCompletionsPast7Days() -> Int {
        let calendar = Calendar.current
        var total = 0
        for habit in habits {
            let last7DaysCompletions = habit.completionDates.filter { date in
                guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return false }
                return date >= sevenDaysAgo
            }
            total += last7DaysCompletions.count
        }
        return total
    }
    
    // MARK: - Network Sync
    
    /// Syncs the computed analytics to your Flask backend via the /stats endpoint.
    func syncAnalyticsToServer(userID: String,
                               totalHabits: Int,
                               longestStreak: Int,
                               perfectDays: Int,
                               totalCompletions: Int) {
        let payload: [String: Any] = [
            "user_id": userID,
            "total_habits": totalHabits,
            "longest_streak": longestStreak,
            "perfect_days": perfectDays,
            "total_completions": totalCompletions
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5001/stats"),
              let jsonData = try? JSONSerialization.data(withJSONObject: payload)
        else {
            print("❌ Invalid URL or JSON encoding error")
            return
        }
        
        print("Sending payload to server: \(payload)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error syncing stats: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No valid HTTP response syncing stats")
                return
            }
            if httpResponse.statusCode == 200 {
                print("✅ Stats synced successfully with the server.")
            } else {
                print("❌ Server error syncing stats: \(httpResponse.statusCode)")
                if let data = data,
                   let responseStr = String(data: data, encoding: .utf8) {
                    print("Response body:", responseStr)
                }
            }
        }.resume()
    }
}
