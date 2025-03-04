////
////  FirebaseLeaderboardService.swift
////  habitfy Watch App
////
////  Created by Mark Dennis on 19/02/2025.
////
//
//import FirebaseFirestore
//import Foundation
//
//class FirebaseLeaderboardService: LeaderboardServiceProtocol {
//    private let db: Firestore
//    private let friendCollection: CollectionReference
//
//    init() {
//        self.db = Firestore.firestore()
//        self.friendCollection = db.collection("Friend")
//    }
//
//    func fetchLeaderboard(completion: @escaping (Result<[Friend], Error>) -> Void) {
//        friendCollection
//            .order(by: "totalCompletionsLast7Days", descending: true)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    completion(.failure(error))
//                } else if let snapshot = snapshot {
//                    var friends: [Friend] = []
//                    for document in snapshot.documents {
//                        if let friend = self.friendFromDocument(document) {
//                            friends.append(friend)
//                        }
//                    }
//                    completion(.success(friends))
//                }
//            }
//    }
//
//    func updateFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
//        let data: [String: Any] = [
//            "name": friend.name,
//            "bestStreak": friend.bestStreak,
//            "totalCompletionsLast7Days": friend.totalCompletionsLast7Days
//        ]
//        
//        // Use the friend's UUID as the document ID.
//        friendCollection.document(friend.id.uuidString).setData(data) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//    
//    private func friendFromDocument(_ document: DocumentSnapshot) -> Friend? {
//        guard let data = document.data(),
//              let name = data["name"] as? String,
//              let bestStreak = data["bestStreak"] as? Int,
//              let totalCompletions = data["totalCompletionsLast7Days"] as? Int else {
//            return nil
//        }
//        
//        // Create a Friend instance. We assume the document ID is the UUID.
//        let id = UUID(uuidString: document.documentID) ?? UUID()
//        return Friend(id: id, name: name, bestStreak: bestStreak, totalCompletionsLast7Days: totalCompletions)
//    }
//}
