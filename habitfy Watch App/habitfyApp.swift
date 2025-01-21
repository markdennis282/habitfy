//
//  habitfyApp.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import SwiftUI
import UserNotifications

@main
struct MyHabitAppApp: App {
    init() {
        // Ask for notification permission when the app starts
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications granted.")
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Notifications not granted.")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
