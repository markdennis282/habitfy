
import SwiftUI
//sign in replicating apples sign in is what would be used in future 
struct SignInView: View {
    @Binding var isSignedIn: Bool
    @Binding var currentUserID: String?
    
    @EnvironmentObject var habitStore: HabitStore
    
    @State private var userName: String = ""
    
    private let backendURL = "http://127.0.0.1:5001/login"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Habitfy")
                .font(.headline)
                .padding(.top, 12)
            
            Button(action: presentTextInput) {
                HStack {
                    if userName.isEmpty {
                        Text("Enter your name")
                            .foregroundColor(.gray)
                    } else {
                        Text(userName)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "mic.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            
            AppleSignInButton {
                handleCustomSignIn()
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .onAppear {
            loadUserSession()
        }
    }
    
    //handle speech recognition
    private func presentTextInput() {
        let controller = WKExtension.shared().rootInterfaceController
        controller?.presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) { result in
            if let texts = result as? [String], let spokenText = texts.first {
                userName = spokenText
            }
        }
    }
    
    //save details locally send device id and name to back end and sync stats
    private func handleCustomSignIn() {
        let displayName = userName.isEmpty ? "Demo User" : userName
        
        let deviceID = getOrCreateDeviceID()
        
        UserDefaults.standard.set(displayName, forKey: "displayName")
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        UserDefaults.standard.set(deviceID, forKey: "userID")
        
        print("Stored userID: \(deviceID) in UserDefaults")
        
        sendDeviceIDToBackend(deviceID, name: displayName)
        
        currentUserID = deviceID
        isSignedIn = true
        
        habitStore.syncAnalytics()
        
        print("✅ Custom Sign-In Successful")
        print("✅ Device/User ID: \(deviceID)")
    }
    
    //if already signed in retrive the devices details
    private func loadUserSession() {
        let isAlreadySignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        
        if isAlreadySignedIn {
            if let savedUserID = UserDefaults.standard.string(forKey: "userID") {
                currentUserID = savedUserID
                isSignedIn = true
                print("✅ Loaded saved session: \(savedUserID)")
            } else {
                print("❌ 'isSignedIn' is true but no 'userID' found")
            }
            
            if let savedName = UserDefaults.standard.string(forKey: "displayName") {
                userName = savedName
            }
        } else {
            print("❌ No saved session found")
        }
    }
    // gets or creates a new device that has been signed in
    private func getOrCreateDeviceID() -> String {
        if let existingID = UserDefaults.standard.string(forKey: "userID") {
            return existingID
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "userID")
            return newID
        }
    }
    
    //send details to backend 
    private func sendDeviceIDToBackend(_ deviceID: String, name: String) {
        guard let url = URL(string: backendURL) else {
            print("❌ Invalid backend URL.")
            return
        }
        
        let bodyDict: [String: Any] = [
            "device_id": deviceID,
            "name": name
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict) else {
            print("❌ Failed to encode JSON.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
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
                print("✅ Server response: \(responseObj)")
            } else {
                print("❌ Server error. Status code:", httpResponse.statusCode)
                if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                    print("Response body:", responseStr)
                }
            }
        }.resume()
    }
}
