
import SwiftUI

struct FriendsView: View {
    @ObservedObject var store: HabitStore
    @State private var currentUserInfo: UserInfo? = nil
    
    var body: some View {
        Form {
            if let userInfo = currentUserInfo {
                Section(header: Text("ID: \(userInfo.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)) {
                    EmptyView()  // No row content, just the header.
                }
            }
            
            Section(header: Text("Your Friends")) {
                if store.friends.isEmpty {
                    Text("No friends added yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(store.friends, id: \.id) { friend in
                        HStack {
                            Text(friend.name)
                                .font(.body)
                            Spacer()
                            Text("ID: \(friend.id)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: removeFriend)
                }
            }
            
            Section {
                NavigationLink(destination: AddFriendView(store: store)) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Add Friend")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let deviceID = UserDefaults.standard.string(forKey: "userID") {
                fetchCurrentUserInfo(deviceID: deviceID)
                store.fetchFriends(userID: deviceID)
            }
        }
    }
    
    //get from backend 
    private func fetchCurrentUserInfo(deviceID: String) {
        guard let url = URL(string: "http://127.0.0.1:5001/users") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let users = try JSONDecoder().decode([UserInfo].self, from: data)
                
                if let currentUser = users.first(where: { $0.deviceID == deviceID }) {
                    DispatchQueue.main.async {
                        self.currentUserInfo = currentUser
                    }
                } else if let currentUser = users.first(where: { String($0.id) == deviceID }) {
                    DispatchQueue.main.async {
                        self.currentUserInfo = currentUser
                    }
                }
            } catch {
                print("Error decoding users: \(error)")
            }
        }.resume()
    }
    
    
    private func removeFriend(at offsets: IndexSet) {
        for index in offsets {
            let friend = store.friends[index]
            store.removeFriendFromBackend(friend)
        }
    }
}
