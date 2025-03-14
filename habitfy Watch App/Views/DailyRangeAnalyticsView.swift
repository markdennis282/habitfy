
import Foundation
import SwiftUI
import Charts

struct DailyRangeAnalyticsView: View {
    @ObservedObject var store: HabitStore
    let dayRange: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Last \(dayRange) Days")
                    .font(.headline)
                
                if #available(watchOS 9.0, *) {
                    Chart(generateCompletions(forLast: dayRange)) { day in
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
                
                let bestStreak     = computeBestStreak()
                let perfectDays    = computePerfectDays(forLast: dayRange)
                let totalCompleted = computeTotalCompletions(forLast: dayRange)
                let dailyAverage: Double = dayRange <= 0 ? 0 : Double(totalCompleted) / Double(dayRange)
                
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 12) {
                    StatBoxView(title: "Best Streak", value: "\(bestStreak)")
                    StatBoxView(title: "Perfect Days", value: "\(perfectDays)")
                    StatBoxView(title: "Total Done",  value: "\(totalCompleted)")
                    StatBoxView(title: "Daily Average",   value: String(format: "%.1f", dailyAverage))
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }
    //get data for date range
    private func generateCompletions(forLast dayRange: Int) -> [DailyCompletion] {
        var results = [DailyCompletion]()
        let calendar = Calendar.current
        
        for i in 0..<dayRange {
            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let count = store.habits.reduce(0) { partial, habit in
                    partial + habit.completionDates.filter {
                        calendar.isDate($0, inSameDayAs: day)
                    }.count
                }
                results.append(DailyCompletion(date: day, count: count))
            }
        }
        return results.sorted { $0.date < $1.date }
    }
    
    private func computeBestStreak() -> Int {
        store.habits.map(\.streak).max() ?? 0
    }
    
    private func computePerfectDays(forLast dayRange: Int) -> Int {
        let calendar = Calendar.current
        let totalHabits = store.habits.count
        guard totalHabits > 0 else { return 0 }
        
        var perfectCount = 0
        for i in 0..<dayRange {
            if let day = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let completedAll = store.habits.allSatisfy { habit in
                    habit.completionDates.contains {
                        calendar.isDate($0, inSameDayAs: day)
                    }
                }
                if completedAll { perfectCount += 1 }
            }
        }
        return perfectCount
    }
    
    private func computeTotalCompletions(forLast dayRange: Int) -> Int {
        let calendar = Calendar.current
        var total = 0
        for habit in store.habits {
            let completionsInRange = habit.completionDates.filter { date in
                guard let rangeStart = calendar.date(byAdding: .day, value: -dayRange, to: Date()) else {
                    return false
                }
                return date >= rangeStart
            }
            total += completionsInRange.count
        }
        return total
    }
}
