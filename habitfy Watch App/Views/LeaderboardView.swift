////
////  LeaderboardView.swift
////  habitfy Watch App
////
////  Created by Mark Dennis on 29/01/2025.
////
//
//import SwiftUI
//
//struct LeaderboardView: View {
//    @ObservedObject var store: HabitStore
//    private let stubService = StubLeaderboardService()
//    
//    var body: some View {
//        VStack {
//            // Pre-sort the friends array.
//            let sortedFriends = store.friends.sorted {
//                $0.totalCompletionsLast7Days > $1.totalCompletionsLast7Days
//            }
//            
//            List(Array(sortedFriends.enumerated()), id: \.1.id) { (index, friend) in
//                HStack {
//                    Text("#\(index + 1)")
//                        .fontWeight(.bold)
//                        .frame(width: 30, alignment: .leading)
//                    
//                    VStack(alignment: .leading) {
//                        Text(friend.name)
//                            .font(.headline)
//                        Text("Best Streak: \(friend.bestStreak)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("\(friend.totalCompletionsLast7Days)")
//                        .font(.headline)
//                        .padding(.trailing, 8)
//                }
//                .padding(.vertical, 4)
//            }
//        }
//        .navigationTitle("Leaderboard")
//        .onAppear {
//            stubService.fetchLeaderboard { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let friends):
//                        store.friends = friends
//                    case .failure(let error):
//                        print("Error fetching leaderboard: \(error)")
//                    }
//                }
//            }
//        }
//    }
//}


import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var store: HabitStore
    // Instead of the stub service, we now use the CloudKit service.
    private let databaseService = StubLeaderboardService()
    
    var body: some View {
        VStack {
            // Pre-sort the friends array.
            let sortedFriends = store.friends.sorted {
                $0.totalCompletionsLast7Days > $1.totalCompletionsLast7Days
            }
            
            List(Array(sortedFriends.enumerated()), id: \.1.id) { (index, friend) in
                HStack {
                    Text("#\(index + 1)")
                        .fontWeight(.bold)
                        .frame(width: 30, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(friend.name)
                            .font(.headline)
                        Text("Best Streak: \(friend.bestStreak)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(friend.totalCompletionsLast7Days)")
                        .font(.headline)
                        .padding(.trailing, 8)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Leaderboard")
        .onAppear {
            // Use the database service to fetch the leaderboard.
            databaseService.fetchLeaderboard { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let friends):
                        store.friends = friends
                    case .failure(let error):
                        print("Error fetching leaderboard: \(error)")
                    }
                }
            }
        }
    }
}










//import SwiftUI
//
//struct LeaderboardView: View {
//    @ObservedObject var store: HabitStore
//    
//    var body: some View {
//        VStack {
//            
//            let sortedFriends = store.friends.sorted {
//                $0.totalCompletionsLast7Days > $1.totalCompletionsLast7Days
//            }
//            
//            List(Array(sortedFriends.enumerated()), id: \.1.id) { (index, friend) in
//                HStack {
//                    Text("#\(index + 1)")
//                        .fontWeight(.bold)
//                        .frame(width: 30, alignment: .leading)
//                    
//                    VStack(alignment: .leading) {
//                        Text(friend.name)
//                            .font(.headline)
//                        Text("Best Streak: \(friend.bestStreak)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("\(friend.totalCompletionsLast7Days)")
//                        .font(.headline)
//                        .padding(.trailing, 8)
//                }
//                .padding(.vertical, 4)
//            }
//        }
//        .navigationTitle("Leaderboard")
//    }
//}


//import SwiftUI
//
//struct LeaderboardView: View {
//    @StateObject private var viewModel = LeaderboardViewModel()
//    
//    var body: some View {
//        VStack {
//            if viewModel.isLoading {
//                ProgressView("Loading leaderboard...")
//            } else {
//                List {
//                    // Using indices helps simplify type inference.
//                    ForEach(viewModel.friends.indices, id: \.self) { index in
//                        LeaderboardRow(index: index, friend: viewModel.friends[index])
//                    }
//                }
//            }
//        }
//        .navigationTitle("Leaderboard")
//        .onAppear {
//            viewModel.loadLeaderboard()
//        }
//    }
//}
//import SwiftUI
//
//struct LeaderboardView: View {
//    @StateObject private var viewModel = LeaderboardViewModel()
//    
//    var body: some View {
//        VStack {
//            if viewModel.isLoading {
//                ProgressView("Loading leaderboard...")
//            } else {
//                List {
//                    ForEach(viewModel.sortedFriends.indices, id: \.self) { index in
//                        LeaderboardRow(index: index, friend: viewModel.sortedFriends[index])
//                    }
//                }
//            }
//        }
//        .navigationTitle("Leaderboard")
//        .onAppear {
//            viewModel.loadLeaderboard()
//        }
//    }
//}
