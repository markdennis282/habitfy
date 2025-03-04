//
//  LeaderboardRow.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//

import SwiftUI

struct LeaderboardRow: View {
    let index: Int
    let friend: Friend
    
    var body: some View {
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
