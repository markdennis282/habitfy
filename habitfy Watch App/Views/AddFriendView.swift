
import SwiftUI
import WatchKit

struct AddFriendView: View {
    @ObservedObject var store: HabitStore
    @Environment(\.dismiss) var dismiss
    
    @State private var friendID: String = ""
    @State private var statusMessage: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Friend Details")) {
                Button(action: {
                    presentTextInput()
                }) {
                    HStack {
                        if friendID.isEmpty {
                            Text("Enter Friend's ID")
                                .foregroundColor(.gray)
                        } else {
                            Text(friendID)
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
            
            Section {
                Button("Add Friend") {
                    addFriendAction()
                }
                .disabled(friendID.isEmpty)
            }
            
            if !statusMessage.isEmpty {
                Section {
                    Text(statusMessage)
                        .foregroundColor(statusMessage.contains("✅") ? .green : .red)
                }
            }
        }
        .navigationTitle("Add Friend")
    }
    
    //to handle speech
    private func presentTextInput() {
        #if os(watchOS)
        let controller = WKExtension.shared().rootInterfaceController
        controller?.presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) { result in
            if let result = result as? [String], let spokenText = result.first {
                friendID = spokenText
            }
        }
        #else
        print("iOS/macOS: Present a custom text input if desired.")
        #endif
    }
    //backedn to add friend
    private func addFriendAction() {
        guard let userID = UserDefaults.standard.string(forKey: "userID"),
              let friendIDInt = Int(friendID) else {
            statusMessage = "❌ Invalid Friend ID"
            return
        }
        
        store.addFriend(userID: userID, friendID: friendIDInt) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    statusMessage = "✅ Friend added successfully!"
                    store.fetchFriends(userID: userID)
                    friendID = ""
                    dismiss()
                } else {
                    statusMessage = "❌ \(errorMessage ?? "Unknown error")"
                }
            }
        }
    }
}
