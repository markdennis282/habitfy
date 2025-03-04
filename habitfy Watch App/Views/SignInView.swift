//
//  SignInView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 07/02/2025.
//

//import SwiftUI
//import AuthenticationServices
//struct SignInView: View {
//    // We’ll bind these to ContentView’s states
//    @Binding var isSignedIn: Bool
//    @Binding var currentUserID: String?
//
//    var body: some View {
//        VStack {
//            Text("Welcome to Habitfy")
//                .font(.headline)
//                .padding(.bottom, 12)
//            
//            // The watch-friendly Sign in with Apple button
//            SignInWithAppleButton(
//                .signIn,
//                onRequest: configure,
//                onCompletion: handle
//            )
//            .signInWithAppleButtonStyle(.whiteOutline)
//            .frame(height: 44)
//        }
//    }
//    
//    private func configure(_ request: ASAuthorizationAppleIDRequest) {
//        // Request a name if you want it (Apple only provides it once)
//        request.requestedScopes = [.fullName]
//    }
//    
//    private func handle(_ result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let authorization):
//            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                // Apple’s unique user ID
//                let userID = credential.user
//                
//                // If needed, fetch the user’s name (available only on FIRST sign-in)
//                let fullName = credential.fullName
//                let displayName = [fullName?.givenName, fullName?.familyName]
//                    .compactMap { $0 }
//                    .joined(separator: " ")
//                
//                // Store locally (for example, in UserDefaults)
//                UserDefaults.standard.set(userID, forKey: "userID")
//                if !displayName.isEmpty {
//                    UserDefaults.standard.set(displayName, forKey: "displayName")
//                }
//                
//                // Update bindings to reflect sign-in
//                currentUserID = userID
//                isSignedIn = true
//            }
//            
//        case .failure(let error):
//            print("Sign in with Apple error: \(error)")
//            // You could show an alert or retry...
//        }
//    }
//}
//
//




//
//
//import SwiftUI
//import AuthenticationServices
//
//struct SignInView: View {
//    @Binding var isSignedIn: Bool
//    @Binding var currentUserID: String?
//
//    var body: some View {
//        VStack {
//            Text("Welcome to Habitfy")
//                .font(.headline)
//                .padding(.bottom, 12)
//            
//            SignInWithAppleButton(
//                .signIn,
//                onRequest: configure,
//                onCompletion: handleStub
//            )
//            .signInWithAppleButtonStyle(.whiteOutline)
//            .frame(height: 44)
//        }
//        .onAppear {
//            loadUserSession() // Load saved user session when the view appears
//        }
//    }
//    
//    private func configure(_ request: ASAuthorizationAppleIDRequest) {
//        request.requestedScopes = [.fullName]
//    }
//    
//    /// Handles a stubbed Apple Sign-In (Fake Login)
//    private func handleStub(_ result: Result<ASAuthorization, Error>) {
//        let stubUserID = "stub-user-\(UUID().uuidString)"
//        let stubDisplayName = "Demo User"
//
//        UserDefaults.standard.set(stubUserID, forKey: "userID")
//        UserDefaults.standard.set("Demo User", forKey: "displayName")
//        UserDefaults.standard.set(true, forKey: "isSignedIn")
//
//        // Update UI state bindings
//        currentUserID = stubUserID
//        isSignedIn = true
//
//        // Debugging logs to check in Xcode
//        print("✅ Stubbed Sign-In Successful")
//        print("✅ User ID set to: \(stubUserID)")
//    }
//
//    /// Loads the user's session from UserDefaults on app launch
//    private func loadUserSession() {
//        if let savedUserID = UserDefaults.standard.string(forKey: "userID"),
//           UserDefaults.standard.bool(forKey: "isSignedIn") {
//            currentUserID = savedUserID
//            isSignedIn = true
//            print("✅ Loaded saved session: \(savedUserID)")
//        } else {
//            print("❌ No saved session found")
//        }
//    }
//}
//
//
//
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Binding var isSignedIn: Bool
    @Binding var currentUserID: String?
    
    // Inject the HabitStore to trigger analytics sync after sign-in.
    @EnvironmentObject var habitStore: HabitStore

    // Change this to your Flask server’s URL and port
    private let backendURL = "http://127.0.0.1:5001/login"  // e.g., your local dev server

    var body: some View {
        VStack {
            Text("Welcome to Habitfy")
                .font(.headline)
                .padding(.bottom, 12)

            SignInWithAppleButton(
                .signIn,
                onRequest: configure,
                onCompletion: handleStubSignIn
            )
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(height: 44)
        }
        .onAppear {
            loadUserSession() // Load saved user session when the view appears
        }
    }

    // MARK: - Apple sign-in config (though we’re just stubbing)
    private func configure(_ request: ASAuthorizationAppleIDRequest) {
        // Even if we request a name/email, this is a mock, so it won’t be used.
        request.requestedScopes = [.fullName]
    }

    // MARK: - Stubbed Apple Sign-In Handler
    private func handleStubSignIn(_ result: Result<ASAuthorization, Error>) {
        // 1) Get or create our “device ID” (fake user ID).
        let deviceID = getOrCreateDeviceID()

        // 2) Optionally, store a “display name” in UserDefaults. Just an example.
        let stubDisplayName = "Demo User"
        UserDefaults.standard.set(stubDisplayName, forKey: "displayName")

        // 3) Mark the user as signed in
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        
        // **Store the deviceID as the userID**
        UserDefaults.standard.set(deviceID, forKey: "userID")
        print("Stored userID: \(deviceID) in UserDefaults")

        // 4) Send the deviceID to the backend
        sendDeviceIDToBackend(deviceID)

        // 5) Update SwiftUI state
        currentUserID = deviceID
        isSignedIn = true

        // 6) Trigger syncAnalytics() after sign-in
        habitStore.syncAnalytics()

        print("✅ Stubbed Sign-In Successful")
        print("✅ Device/User ID: \(deviceID)")
    }

    // MARK: - Load existing user session if it exists
    private func loadUserSession() {
        let isAlreadySignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        if isAlreadySignedIn, let savedDeviceID = UserDefaults.standard.string(forKey: "deviceID") {
            // We have a saved device ID
            currentUserID = savedDeviceID
            isSignedIn = true
            print("✅ Loaded saved session: \(savedDeviceID)")
        } else {
            print("❌ No saved session found")
        }
    }

    // MARK: - Generate or Retrieve a Device ID
    private func getOrCreateDeviceID() -> String {
        if let existingID = UserDefaults.standard.string(forKey: "deviceID") {
            // Already have a device ID, just return it
            return existingID
        } else {
            // Create a new one and store it
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "deviceID")
            return newID
        }
    }

    // MARK: - Send device ID to the Flask backend
    private func sendDeviceIDToBackend(_ deviceID: String) {
        guard let url = URL(string: backendURL) else {
            print("❌ Invalid backend URL.")
            return
        }

        // Build JSON body
        let bodyDict = ["device_id": deviceID]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict) else {
            print("❌ Failed to encode JSON.")
            return
        }

        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No valid HTTP response.")
                return
            }

            if httpResponse.statusCode == 200,
               let data = data,
               let responseObj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Handle success
                print("✅ Server response: \(responseObj)")
            } else {
                // Handle error or unexpected response
                print("❌ Server error. Status code:", httpResponse.statusCode)
                if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                    print("Response body:", responseStr)
                }
            }
        }.resume()
    }
}
