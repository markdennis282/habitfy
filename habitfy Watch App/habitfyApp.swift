////
////  habitfyApp.swift
////  habitfy Watch App
////
////  Created by Mark Dennis on 20/01/2025.
////
//
//import SwiftUI
//import UserNotifications
//
//@main
//struct HabitfyApp: App {
//    // Load user state from UserDefaults
//    @State private var isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
//    @State private var currentUserID = UserDefaults.standard.string(forKey: "userID")
//
//    init() {
//        // Request Notification Permission
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("✅ Notifications granted.")
//            } else if let error = error {
//                print("❌ Error: \(error.localizedDescription)")
//            } else {
//                print("❌ Notifications not granted.")
//            }
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            if isSignedIn {
//                ContentView() // User is signed in, show main app
//            } else {
//                SignInView(isSignedIn: $isSignedIn, currentUserID: $currentUserID)
//            }
//        }
//    }
//}




import SwiftUI
import UserNotifications
import FirebaseCore

// MARK: - App Delegate for Firebase Setup
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

@main
struct HabitfyApp: App {
    // Register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Load user state from UserDefaults
    @State private var isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
    @State private var currentUserID = UserDefaults.standard.string(forKey: "userID")
    

    init() {
        // Request Notification Permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications granted.")
            } else if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            } else {
                print("❌ Notifications not granted.")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isSignedIn {
                ContentView() // User is signed in, show main app
            } else {
                SignInView(isSignedIn: $isSignedIn, currentUserID: $currentUserID)
            }
        }
    }
}
