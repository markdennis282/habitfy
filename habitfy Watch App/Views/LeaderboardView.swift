
import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var store: HabitStore//looks at data from store
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if store.leaderboardEntries.isEmpty {
                        Text("No Leaderboard Entries")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(Array(store.leaderboardEntries.enumerated()), id: \.offset) { index, entry in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(getRankColor(for: index))
                                    .clipShape(Circle())
                                    .accessibilityLabel("Rank \(index + 1)")
                                
                                Text(entry.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    if entry.longestStreak > 0 {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                            .accessibilityLabel("Active streak")
                                    }
                                    Text("\(entry.longestStreak)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityLabel("Longest streak \(entry.longestStreak) days")
                            }
                            .padding(.vertical, 2)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(entry.name), rank \(index + 1), longest streak \(entry.longestStreak) days")
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                store.fetchLeaderboard()
            }
            .onAppear {
                store.fetchLeaderboard()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    //get colour of each rank
    private func getRankColor(for index: Int) -> Color {
        switch index {
        case 0:
            return .yellow
        case 1:
            return .gray
        case 2:
            return .brown
        default:
            return .blue 
        }
    }
}
