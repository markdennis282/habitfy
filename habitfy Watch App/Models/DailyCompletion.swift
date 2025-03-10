import Foundation
struct DailyCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
