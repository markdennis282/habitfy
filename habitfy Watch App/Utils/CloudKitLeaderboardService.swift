//
//  CloudKitLeaderboardService.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 17/02/2025.
//

import CloudKit
import Foundation

class CloudKitLeaderboardService: LeaderboardServiceProtocol {
    private let container: CKContainer
    private let database: CKDatabase

    init(container: CKContainer = CKContainer.default()) {
        self.container = container
        // Use the public database for leaderboard data.
        self.database = container.publicCloudDatabase
    }

    func fetchLeaderboard(completion: @escaping (Result<[Friend], Error>) -> Void) {
        // Create a query that fetches all "Friend" records.
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Friend", predicate: predicate)
        // Sort descending by totalCompletionsLast7Days.
        query.sortDescriptors = [NSSortDescriptor(key: "totalCompletionsLast7Days", ascending: false)]
        
        var fetchedFriends: [Friend] = []
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            if let friend = self.friendFromRecord(record) {
                fetchedFriends.append(friend)
            }
        }
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(fetchedFriends))
            }
        }
        database.add(operation)
    }
    
    func updateFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use the friend's UUID as the record name so that updates overwrite the same record.
        let recordID = CKRecord.ID(recordName: friend.id.uuidString)
        let record = CKRecord(recordType: "Friend", recordID: recordID)
        record["name"] = friend.name as CKRecordValue
        record["bestStreak"] = friend.bestStreak as CKRecordValue
        record["totalCompletionsLast7Days"] = friend.totalCompletionsLast7Days as CKRecordValue
        
        database.save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Convert a CKRecord to a Friend.
    private func friendFromRecord(_ record: CKRecord) -> Friend? {
        guard let name = record["name"] as? String,
              let bestStreak = record["bestStreak"] as? Int,
              let totalCompletions = record["totalCompletionsLast7Days"] as? Int else {
            return nil
        }
        return Friend(name: name, bestStreak: bestStreak, totalCompletionsLast7Days: totalCompletions)
    }
}
