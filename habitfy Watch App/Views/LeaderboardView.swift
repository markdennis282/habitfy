//
//  LeaderboardView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 29/01/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var store: HabitStore
    
    var body: some View {
        VStack {
            
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
    }
}
