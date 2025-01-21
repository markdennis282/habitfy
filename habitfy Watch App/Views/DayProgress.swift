//
//  DayProgress.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 21/01/2025.
//

import Foundation
import SwiftUI

/// Represents one day's progress data: how many habits are completed vs total.
struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let completedHabits: Int
    let totalHabits: Int
    
    /// Fraction (0.0 to 1.0) of completed habits for the day.
    var completionFraction: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedHabits) / Double(totalHabits)
    }
    
    /// Example: "Mon", "Tue", "Wed".
    var weekdayAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // 3-letter abbreviation
        return formatter.string(from: date)
    }
    
    /// Example: "21" for the 21st day of the month.
    var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

/// A ring view that shows a partial circle to represent progress.
/// e.g., fraction=0.5 means half the circle is filled.
struct ProgressRingView: View {
    var fraction: Double      // 0.0 means empty, 1.0 means full
    var lineWidth: CGFloat = 5
    var ringColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(backgroundColor)
            
            // Foreground ring (trim by fraction)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(fraction, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(ringColor)
                .rotationEffect(Angle(degrees: -90)) // Start at top
        }
    }
}

/// Displays a day’s info: abbreviated weekday on top, a ring with date in the center.
/// If the day is fully complete (fraction == 1.0), the background circle is filled.
struct DayCircleView: View {
    let day: DayProgress
    
    var body: some View {
        VStack(spacing: 4) {
            // Abbreviated weekday, e.g. "Tue"
            Text(day.weekdayAbbrev)
                .font(.caption2)
                .foregroundColor(.gray)
            
            ZStack {
                // If fully completed, fill the circle behind the ring.
                if day.completionFraction >= 1.0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                }
                
                // The ring for partial or full completion.
                ProgressRingView(
                    fraction: day.completionFraction,
                    lineWidth: 4,
                    ringColor: .blue,
                    backgroundColor: Color.white.opacity(0.1)
                )
                .frame(width: 40, height: 40)
                
                // Day number in the center.
                Text(day.dayNumberString)
                    .font(.caption)
                    .foregroundColor(day.completionFraction >= 1.0 ? .white : .primary)
            }
        }
    }
}

/// Shows multiple days horizontally. Each circle can be connected by a line.
/// If both days are fully complete, line is blue; else it's gray.
struct DateProgressTimelineView: View {
    let days: [DayProgress]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<days.count, id: \.self) { i in
                    ZStack {
                        DayCircleView(day: days[i])
                    }
                    .overlay(
                        // Draw a line from this day to the next day (unless it's the last).
                        i < days.count - 1
                            ? AnyView(lineToNextDay(current: days[i], next: days[i+1]))
                            : AnyView(EmptyView()),
                        alignment: .trailing
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    /// Draws a horizontal line connecting two adjacent days.
    private func lineToNextDay(current: DayProgress, next: DayProgress) -> some View {
        // If both are fully completed, use blue; otherwise use gray.
        let bothComplete = (current.completionFraction == 1.0) && (next.completionFraction == 1.0)
        let lineColor: Color = bothComplete ? .blue : .gray
        
        return Rectangle()
            .fill(lineColor)
            .frame(width: 50, height: 2)
            // Offset so it lines up between the circles
            .offset(x: 35)
    }
}

/// Example usage in a single-file approach:
/// This is just for preview / demonstration; you can integrate it into your watch app.
struct DateProgressTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        // Generate 5 sample days
        let calendar = Calendar.current
        var sampleDays: [DayProgress] = []
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: i - 2, to: Date()) {
                // Let's say each day has 4 habits, with a random number completed
                let total = 4
                let completed = Int.random(in: 0...4)
                sampleDays.append(
                    DayProgress(date: date, completedHabits: completed, totalHabits: total)
                )
            }
        }
        
        return Group {
            DateProgressTimelineView(days: sampleDays)
                .frame(height: 100)
                .previewDevice("Apple Watch Series 6 - 44mm")

            // For iPhone preview (just to see it bigger)
            DateProgressTimelineView(days: sampleDays)
                .frame(height: 100)
                .previewDevice("iPhone 14")
        }
    }
}
