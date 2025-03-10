
struct LeaderboardEntry: Codable {
    let id: Int
    let name: String
    let longestStreak: Int
    let totalHabits: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case longestStreak = "longest_streak"
        case totalHabits = "total_habits"
    }
}
