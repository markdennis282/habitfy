

import Foundation

struct Friend: Identifiable, Codable, Equatable {//codeable to allow to send as json data
    let id: Int
    var name: String
    var bestStreak: Int?
    var totalCompletionsLast7Days: Int?

    enum CodingKeys: String, CodingKey {//make compatable with api responses
        case id
        case name
        case bestStreak = "longest_streak"
        case totalCompletionsLast7Days = "total_completions"
    }
    
    init(id: Int, name: String, bestStreak: Int? = nil, totalCompletionsLast7Days: Int? = nil) {
        self.id = id
        self.name = name
        self.bestStreak = bestStreak
        self.totalCompletionsLast7Days = totalCompletionsLast7Days
    }
    
    static func == (lhs: Friend, rhs: Friend) -> Bool {//dont allow dups
        lhs.id == rhs.id
    }
}
