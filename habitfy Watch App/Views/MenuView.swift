//
//  MenuView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 27/01/2025.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var store: HabitStore
    
    // Bring in sign-in state and currentUserID from ContentView
    @Binding var isSignedIn: Bool
    @Binding var currentUserID: String?

    var body: some View {
        List {
            // Today Row (NavigationLink)
            NavigationLink(destination: ContentView()) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Today")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // A small CircularProgressView on the right, if desired
                    CircularProgressView(
                        progress: calculateCompletionFraction(),
                        lineWidth: 6,
                        progressColor: .blue,
                        backgroundColor: .gray.opacity(0.2)
                    )
                    .frame(width: 30, height: 30)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))

            // Add Habit Row (NavigationLink)
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

            // Analytics Row (NavigationLink)
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
            
            // Leaderboard Row (NavigationLink)
            NavigationLink(destination: LeaderboardView(store: store)) {
                HStack {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Leaderboard")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))
            
            // Sign Out Row (Button)
            Button(action: signOut) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Sign Out")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1))
        }
        .navigationTitle("Menu")
    }
    
    // MARK: - Helpers
    
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
    
    // MARK: - Sign Out
    private func signOut() {
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.set(false, forKey: "isSignedIn")

        // Reset local state so ContentView goes back to SignInView
        currentUserID = nil
        isSignedIn = false

        print("✅ User signed out. Returning to login page.")
    }
}
