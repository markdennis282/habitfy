//
//  LeaderboardServiceProtocol.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//

// LeaderboardService.swift
import Foundation

protocol LeaderboardServiceProtocol {
    /// Fetch all friends for the leaderboard.
    func fetchLeaderboard(completion: @escaping (Result<[Friend], Error>) -> Void)
    
    /// Update a friend’s stats.
    func updateFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void)
}

