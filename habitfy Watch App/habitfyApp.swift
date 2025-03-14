

import SwiftUI
import UserNotifications
import FirebaseCore

@main
struct HabitfyApp: App {
    @State private var isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
    @State private var currentUserID = UserDefaults.standard.string(forKey: "userID")
    @StateObject private var store = HabitStore(userID: UserDefaults.standard.string(forKey: "userID") ?? "")

    init() {
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
                ContentView()
                    .environmentObject(store)
            } else {
                SignInView(isSignedIn: $isSignedIn, currentUserID: $currentUserID).environmentObject(store)
            }
        }
    }

    private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.set(false, forKey: "isSignedIn")

        isSignedIn = false
        currentUserID = nil

        store.updateUserID("")
        print("✅ User logged out successfully")
    }
}
