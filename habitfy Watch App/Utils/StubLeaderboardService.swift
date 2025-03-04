//
//  StubLeaderboardService.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//
import SwiftUI

class StubLeaderboardService: LeaderboardServiceProtocol {
    // In-memory array of friends
    private var friends: [Friend] = [
        Friend(name: "Alice", bestStreak: 5, totalCompletionsLast7Days: 10),
        Friend(name: "Bob", bestStreak: 3, totalCompletionsLast7Days: 8)
    ]
    
    func fetchLeaderboard(completion: @escaping (Result<[Friend], Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let sorted = self.friends.sorted { $0.bestStreak > $1.bestStreak }
            completion(.success(sorted))
        }
    }
    
    func updateFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let idx = self.friends.firstIndex(where: { $0.id == friend.id }) {
                self.friends[idx] = friend
            } else {
                self.friends.append(friend)
            }
            completion(.success(()))
        }
    }
}
