//
//  AddHabitView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//
//


import SwiftUI
import UserNotifications
import MapKit
import CoreLocation
import WatchKit

struct AddHabitView: View {
    @ObservedObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    @State private var habitName: String = ""
    
    @State private var reminderTime = Date()
    @State private var enableTimeNotification = false

    @State private var useLocationNotification = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    // Hard-coded radius for location-based notifications
    private let fixedReminderRadius: Double = 100  // in meters

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
                .buttonStyle(PlainButtonStyle())
            }
            
            Section(header: Text("Time Reminder")) {
                Toggle("Set Time Reminder", isOn: $enableTimeNotification)
                
                if enableTimeNotification {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                }
            }
            
            Section(header: Text("Location Reminder")) {
                Toggle("Set Location Reminder", isOn: $useLocationNotification)
                
                if useLocationNotification {
                    // Navigate to map for picking location
                    NavigationLink("Select Location") {
                        LocationPickerView(selectedCoordinate: $selectedCoordinate)
                    }
                    
                    if let coordinate = selectedCoordinate {
                        Text("Location: \(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))")
                    }
                }
            }
            
            Section {
                Button("Save Habit") {
                    let newHabit = Habit(name: habitName,
                                         reminderTime: enableTimeNotification ? reminderTime : nil)
                    store.addHabit(newHabit)
                    
                    // Schedule time-based notification if enabled
                    if enableTimeNotification {
                        scheduleLocalNotification(for: newHabit)
                    }
                    
                    // Schedule location-based notification if enabled and coordinate selected
                    if useLocationNotification, let coordinate = selectedCoordinate {
                        scheduleLocationNotification(for: newHabit, at: coordinate)
                    }
                    
                    dismiss()
                }
                .disabled(habitName.isEmpty)
            }
        }
        .navigationTitle("Add Habit")
    }
    
    // MARK: - Helper Methods
    
    private func presentTextInput() {
        let controller = WKExtension.shared().rootInterfaceController
        controller?.presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) { result in
            if let result = result as? [String], let spokenText = result.first {
                habitName = spokenText
            }
        }
    }
    
    /// Schedule a time-based local notification.
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
                print("Error scheduling time notification: \(error)")
            }
        }
    }
    
    /// Schedule a location-based notification with a fixed radius of 100 meters.
    private func scheduleLocationNotification(for habit: Habit, at coordinate: CLLocationCoordinate2D) {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "You're near your location for: \(habit.name)"
        content.sound = .default
        
        // Fixed radius of 100 meters
        let region = CLCircularRegion(
            center: coordinate,
            radius: fixedReminderRadius,
            identifier: habit.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString + "-location",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling location notification: \(error)")
            }
        }
    }
}
