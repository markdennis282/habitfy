//
//  AddHabitView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import SwiftUI
import Combine
import UserNotifications


struct AddHabitView: View {
    @ObservedObject var store: HabitStore
    @Environment(\.dismiss) var dismiss
    
    @State private var habitName: String = ""
    @State private var reminderTime = Date()
    
    var body: some View {
        Form {
            TextField("Habit Name", text: $habitName)
            
            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
            
            Button("Save") {
                let newHabit = Habit(name: habitName, reminderTime: reminderTime)
                store.addHabit(newHabit)
                scheduleLocalNotification(for: newHabit)
                dismiss()
            }
        }
        .navigationTitle("Add Habit")
    }
    
    // 5. Scheduling Notifications
    private func scheduleLocalNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to complete: \(habit.name)"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: habit.reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

