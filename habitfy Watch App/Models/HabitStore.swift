
import SwiftUI
import Combine
// sync stats manages leaderboard and friends and habit details
class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            print("habits didSet: count = \(habits.count)")
            saveHabits()
            syncAnalytics()
        }
    }
    @Published var friends: [Friend] = []
    @Published var leaderboard: [Friend] = []
    @Published var leaderboardEntries: [LeaderboardEntry] = []

    
    private let storeKey = "habitsKey"
    private var userID: String
//init with user id
    init(userID: String) {
        self.userID = userID
        loadHabits()
    }
//updates user id  and refreshes data
    func updateUserID(_ newUserID: String) {
        self.userID = newUserID

        if newUserID.isEmpty {
            friends = []
        } else {
            loadHabits()
            fetchFriends(userID: newUserID)
            syncAnalytics()
        }
    }
    
    
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
    
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        print("Added habit: \(habit.name), id: \(habit.id)")
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            print("Updated habit: \(habit.name), id: \(habit.id)")
        } else {
            print("❌ Habit not found for update: \(habit.id)")
        }
    }
    
    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        print("Removed habit: \(habit.name), id: \(habit.id)")
    }
    
    func addFriend(_ friend: Friend) {
        friends.append(friend)
        print("Added friend: \(friend.name)")
    }
    
    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
        print("Removed friend: \(friend.name)")
    }
    
    //sync analytics data with backend
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


    func fetchLeaderboard() {
        fetchFriends(userID: userID)
        
        guard let url = URL(string: "http://127.0.0.1:5001/user/id?uuid=\(userID)") else {
            print("Invalid URL for fetching user ID")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Error fetching user ID: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(UserIDResponse.self, from: data)
                if let userIDInt = response.id {
                    // Call fetchLeaderboardStats with the integer ID
                    DispatchQueue.main.async {
                        self.fetchLeaderboardStats(currentUserID: userIDInt)
                    }
                } else {
                    print("Error: User ID not found for UUID \(self.userID)")
                }
            } catch {
                print("Error decoding user ID: \(error)")
            }
        }.resume()
    }
        
    func fetchLeaderboardStats(currentUserID: Int) {
        guard let url = URL(string: "http://127.0.0.1:5001/leaderboard/\(currentUserID)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Error fetching leaderboard: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let entries = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
                let sortedEntries = entries.sorted { (entry1: LeaderboardEntry, entry2: LeaderboardEntry) -> Bool in
                    return entry1.longestStreak > entry2.longestStreak
                }
                
                DispatchQueue.main.async {
                    self.leaderboardEntries = sortedEntries
                    print("Leaderboard updated: \(sortedEntries)")
                }
            } catch {
                print("Error decoding leaderboard: \(error)")
            }
        }.resume()
    }

        func fetchFriends(userID: String) {
            guard let url = URL(string: "http://127.0.0.1:5001/friends/\(userID)") else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching friends: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                if let decodedResponse = try? JSONDecoder().decode([Friend].self, from: data) {
                    DispatchQueue.main.async {
                        self.friends = decodedResponse
                    }
                } else {
                    print("Error decoding friends response")
                }
            }.resume()
        }

        func addFriend(userID: String, friendID: Int, completion: @escaping (Bool, String?) -> Void) {
            guard let url = URL(string: "http://127.0.0.1:5001/friends/add") else {
                completion(false, "Invalid URL")
                return
            }

            let payload: [String: Any] = [
                "user_id": userID,
                "friend_id": friendID
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                completion(false, "JSON encoding error")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    completion(false, "Network error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    let responseMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    completion(false, "Error: \(responseMessage)")
                }
            }.resume()
        }
    
    func removeFriendFromBackend(_ friend: Friend) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("❌ No user ID found; cannot remove friend.")
            return
        }
        guard let url = URL(string: "http://127.0.0.1:5001/friends/remove") else {
            print("❌ Invalid URL for removing friend.")
            return
        }
        
        let payload: [String: Any] = [
            "user_id": userID,
            "friend_id": friend.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ JSON encoding error.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error removing friend:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No valid HTTP response removing friend.")
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.friends.removeAll { $0.id == friend.id }
                    print("✅ Friend removed successfully from backend and local list.")
                }
            } else {
                if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                    print("❌ Server error removing friend: \(responseStr)")
                }
            }
        }.resume()
    }

    
    
}
