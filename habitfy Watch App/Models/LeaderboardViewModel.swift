//
//  LeaderboardViewModel.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//

//import SwiftUI
//
//class LeaderboardViewModel: ObservableObject {
//    @Published var friends: [Friend] = []
//    @Published var isLoading = false
//    
//    private let service: LeaderboardServiceProtocol
//    
//    // Default to the stub service.
//    init(service: LeaderboardServiceProtocol = StubLeaderboardService()) {
//        self.service = service
//    }
//    
//    func loadLeaderboard() {
//        isLoading = true
//        service.fetchLeaderboard { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let data):
//                    self?.friends = data
//                case .failure(let error):
//                    print("Error fetching leaderboard: \(error)")
//                }
//            }
//        }
//    }
//    
//    func updateFriend(friend: Friend) {
//        isLoading = true
//        service.updateFriend(friend) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success():
//                    self?.loadLeaderboard()  // Refresh after update.
//                case .failure(let error):
//                    print("Error updating friend: \(error)")
//                }
//            }
//        }
//    }
//}



import Foundation
import Combine

class LeaderboardViewModel: ObservableObject {
    @Published var friends: [Friend] = [] {
        didSet {
            updateSortedFriends()
        }
    }
    @Published private(set) var sortedFriends: [Friend] = []
    @Published var isLoading = false

    private let service: LeaderboardServiceProtocol

    init(service: LeaderboardServiceProtocol = StubLeaderboardService()) {
        self.service = service
    }
    
    // Update sortedFriends whenever friends change
    private func updateSortedFriends() {
        sortedFriends = friends.sorted { $0.totalCompletionsLast7Days > $1.totalCompletionsLast7Days }
    }

    func loadLeaderboard() {
        isLoading = true
        service.fetchLeaderboard { [weak self] (result: Result<[Friend], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.friends = data  // `didSet` will trigger sorting
                case .failure(let error):
                    print("Error fetching leaderboard: \(error)")
                }
            }
        }
    }
    
    func updateFriend(friend: Friend) {
        isLoading = true
        service.updateFriend(friend) { [weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success():
                    self.loadLeaderboard()  // Refresh after update.
                case .failure(let error):
                    print("Error updating friend: \(error)")
                }
            }
        }
    }
}
