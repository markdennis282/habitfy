//
//  MenuView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 27/01/2025.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var store: HabitStore

    var body: some View {
        List {
            // Today NavigationLink with CircularProgressView
            NavigationLink(destination: ContentView(store: store)) {
                HStack {
                    CircularProgressView(
                        progress: calculateCompletionFraction(),
                        lineWidth: 6,
                        progressColor: .blue,
                        backgroundColor: .gray.opacity(0.2)
                    )
                    .frame(width: 30, height: 30) // Match the icon size
                    
                    Text("Today")
                        .font(.body) // Match the font of other items
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.blue.opacity(0.1)) // Same background as others

            // Add Habit NavigationLink
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

            // Analytics NavigationLink
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
        }
        .navigationTitle("Menu")
    }
    
    private func calculateCompletionFraction() -> Double {
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0.0 }
        
        let completedHabits = store.habits.filter(isHabitCompletedToday).count
        return Double(completedHabits) / Double(totalHabits)
    }
    /// Returns true if the habit is completed today
    private func isHabitCompletedToday(_ habit: Habit) -> Bool {
        let calendar = Calendar.current
        return habit.completionDates.contains { date in
            calendar.isDateInToday(date)
        }
    }
}
