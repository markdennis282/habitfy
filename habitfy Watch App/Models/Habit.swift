
import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID //unique identifier
    let name: String
    let reminderTime: Date?
    var completionDates: [Date]
    var streak: Int
    //init habit with name and streak zero
    init(name: String, reminderTime: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.reminderTime = reminderTime
        self.completionDates = []
        self.streak = 0
    }
}
