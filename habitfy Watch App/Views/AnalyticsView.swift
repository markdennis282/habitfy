//
//  AnalyticsView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import Charts
import SwiftUI
import Combine

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var store: HabitStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Last 7 Days")
                    .font(.headline)
                
                // 1) CHART of daily completions (if watchOS 9+)
                if #available(watchOS 9.0, *) {
                    Chart(generateCompletionsPast7Days()) { day in
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Count", day.count)
                        )
                    }
                    .frame(height: 100)
                } else {
                    Text("Chart not supported on this watchOS version.")
                        .foregroundColor(.secondary)
                }
                
                // 2) Other stats
                let bestStreak = computeBestStreak()
                let perfectDays = computePerfectDaysPast7Days()
                let totalHabitsDone = computeTotalCompletionsPast7Days()
                let dailyAverage: Double = {
                    let comps = generateCompletionsPast7Days()
                    if comps.isEmpty { return 0 }
                    return Double(totalHabitsDone) / 7.0
                }()
                
                // Display in a 2 x 2 grid
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
                
                LazyVGrid(columns: columns, spacing: 12) {
                    StatBoxView(title: "Best Streak", value: "\(bestStreak)")
                    StatBoxView(title: "Perfect Days", value: "\(perfectDays)")
                    StatBoxView(title: "Total Done", value: "\(totalHabitsDone)")
                    StatBoxView(title: "Daily Avg", value: String(format: "%.1f", dailyAverage))
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }
    
    // MARK: - Chart Data (Last 7 Days)
    
    /// We'll group completions by day in the past 7 days.
    private func generateCompletionsPast7Days() -> [DailyCompletion] {
        var results = [DailyCompletion]()
        let calendar = Calendar.current
        
        // For each of the last 7 days
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                // Count how many times any habit was completed on this 'day'
                let count = store.habits.reduce(0) { partialResult, habit in
                    partialResult + habit.completionDates.filter {
                        calendar.isDate($0, inSameDayAs: day)
                    }.count
                }
                results.append(DailyCompletion(date: day, count: count))
            }
        }
        
        // Sort so the earliest day is first
        return results.sorted(by: { $0.date < $1.date })
    }
    
    // MARK: - Compute Stats
    
    /// Best streak across all habits (just max of all streak properties).
    private func computeBestStreak() -> Int {
        store.habits.map(\.streak).max() ?? 0
    }
    
    /// How many days in the last 7 days were "perfect" (meaning every habit was completed).
    private func computePerfectDaysPast7Days() -> Int {
        let calendar = Calendar.current
        let totalHabits = store.habits.count
        
        guard totalHabits > 0 else { return 0 }  // No habits => no perfect days
        
        var perfectCount = 0
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                // For each habit, check if completed this day
                let completedAll = store.habits.allSatisfy { habit in
                    // Did we find a completion date that matches 'day'?
                    habit.completionDates.contains {
                        calendar.isDate($0, inSameDayAs: day)
                    }
                }
                if completedAll {
                    perfectCount += 1
                }
            }
        }
        
        return perfectCount
    }
    
    /// Total number of habit completions in the last 7 days (sum of all completions).
    private func computeTotalCompletionsPast7Days() -> Int {
        let calendar = Calendar.current
        var total = 0
        
        for habit in store.habits {
            let last7DaysCompletions = habit.completionDates.filter { date in
                guard let daysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return false }
                // Count only if within last 7 days
                return date >= daysAgo
            }
            total += last7DaysCompletions.count
        }
        
        return total
    }
}

/// A simple struct for chart data
struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct StatBoxView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
