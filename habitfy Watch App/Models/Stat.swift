
struct Stat: Codable, Identifiable {
    let id: Int
    let last_sync: String
    let longest_streak: Int
    let total_habits: Int
    let user_id: String

    enum CodingKeys: String, CodingKey {
        case id, last_sync, longest_streak, total_habits, user_id
    }
    
    init(from decoder: Decoder) throws {//enables handling of different returns strings or ints
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        last_sync = try container.decode(String.self, forKey: .last_sync)
        longest_streak = try container.decode(Int.self, forKey: .longest_streak)
        total_habits = try container.decode(Int.self, forKey: .total_habits)
        
        if let uid = try? container.decode(String.self, forKey: .user_id) {
            user_id = uid
        } else {
            let uidInt = try container.decode(Int.self, forKey: .user_id)
            user_id = String(uidInt)
        }
    }
}
