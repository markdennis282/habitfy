//
//  AddHabitView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
import SwiftUI
import UserNotifications

struct AddHabitView: View {
    @ObservedObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    @State private var habitName: String = ""
    @State private var reminderTime = Date()
    @State private var enableNotification = false // Toggle for notifications
    
    var body: some View {
        Form {
            Section(header: Text("Habit Details")) {
                Button(action: {
                    presentTextInput()
                }) {
                    HStack {
                        if habitName.isEmpty {
                            Text("Enter Habit")
                                .foregroundColor(.gray)
                        } else {
                            Text(habitName)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "mic.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle()) // Removes button styling to match the form look
            }


            
            Section(header: Text("Reminder")) {
                Toggle("Set Reminder", isOn: $enableNotification)
                
                if enableNotification {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                }
            }
            
            Section {
                Button("Save Habit") {
                    let newHabit = Habit(name: habitName, reminderTime: enableNotification ? reminderTime : nil)
                    store.addHabit(newHabit)
                    
                    if enableNotification {
                        scheduleLocalNotification(for: newHabit)
                    }
                    
                    dismiss()
                }
                .disabled(habitName.isEmpty)
            }
        }
        .navigationTitle("Add Habit")
    }
    
    // Helper Methods
    
    /// Present the text input controller for dictation
    private func presentTextInput() {
        let controller = WKExtension.shared().rootInterfaceController
        controller?.presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) { result in
            if let result = result as? [String], let spokenText = result.first {
                habitName = spokenText
            }
        }
    }
    
    /// Schedule a local notification for the habit
    private func scheduleLocalNotification(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to complete: \(habit.name)"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
