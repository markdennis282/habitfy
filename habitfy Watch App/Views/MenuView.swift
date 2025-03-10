

import SwiftUI
//links all pages together
struct MenuView: View {
    @ObservedObject var store: HabitStore
    
    @Binding var isSignedIn: Bool
    @Binding var currentUserID: String?

    var body: some View {
        List {

            NavigationLink(destination: AddHabitView(store: store)) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Add Habit")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))

            NavigationLink(destination: AnalyticsView(store: store)) {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Analytics")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))
            
            NavigationLink(destination: LeaderboardView(store: store)) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Leaderboard")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))
            
            NavigationLink(destination: FriendsView(store: store)) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("Friends")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.blue.opacity(0.1))
            
            Button(action: signOut) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.red)
                    
                    Text("Sign Out")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))
        }
        .navigationTitle("Menu")
    }
    
    
    private func calculateCompletionFraction() -> Double {
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0.0 }
        
        let completedHabits = store.habits.filter(isHabitCompletedToday).count
        return Double(completedHabits) / Double(totalHabits)
    }
    
    private func isHabitCompletedToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains {
            calendar.isDateInToday($0)
        }
    }
    //signout and reset the signin state to false
    private func signOut() {

        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.set(false, forKey: "isSignedIn")

        store.updateUserID("")

        currentUserID = nil
        isSignedIn = false

        print("✅ User signed out. Habits preserved.")
    }

}
