//
//  CloudKitManager.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 07/02/2025.
//

import Foundation
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    
    private init() {}
    
    // Reference to public CloudKit database
    private let publicDB = CKContainer.default().publicCloudDatabase
    
    /// Sign-in flow: ensure the user record is created or fetched
    func signIn(userID: String, displayName: String?) {
        let recordID = CKRecord.ID(recordName: userID)
        
        publicDB.fetch(withRecordID: recordID) { [weak self] existingRecord, error in
            if let record = existingRecord {
                // Already exists - possibly update displayName if needed
                if let displayName = displayName, !displayName.isEmpty {
                    record["displayName"] = displayName
                    self?.publicDB.save(record) { _, _ in }
                }
            } else if let ckError = error as? CKError, ckError.code == .unknownItem {
                // Record not found, create new
                let newRecord = CKRecord(recordType: "User", recordID: recordID)
                newRecord["displayName"] = displayName ?? "Anonymous"
                newRecord["totalCompletions"] = 0 // start at 0
                self?.publicDB.save(newRecord) { _, saveError in
                    if let saveError = saveError {
                        print("Error saving new user record: \(saveError)")
                    }
                }
            } else if let error = error {
                print("Error fetching user record: \(error)")
            }
        }
    }
    
    /// Update total completions for the signed-in user
    func updateCompletions(for userID: String, newTotal: Int) {
        let recordID = CKRecord.ID(recordName: userID)
        publicDB.fetch(withRecordID: recordID) { [weak self] record, error in
            guard let record = record, error == nil else {
                print("Error fetching user record for update: \(error?.localizedDescription ?? "")")
                return
            }
            record["totalCompletions"] = newTotal
            self?.publicDB.save(record) { _, saveError in
                if let saveError = saveError {
                    print("Error updating completions: \(saveError)")
                }
            }
        }
    }
    
    /// Fetch top users sorted by totalCompletions descending
    func fetchLeaderboard(completion: @escaping ([CKRecord]) -> Void) {
        let query = CKQuery(recordType: "User", predicate: NSPredicate(value: true))
        // Sort by totalCompletions DESC
        let sort = NSSortDescriptor(key: "totalCompletions", ascending: false)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        var results = [CKRecord]()
        
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                results.append(record)
            case .failure(let error):
                print("Error matching record: \(error)")
            }
        }
        
        operation.queryResultBlock = { [weak self] cursorResult in
            // All records in this batch fetched
            // If there's a cursor for more records, you'd fetch again
            // but for a simple leaderboard, maybe you just want first ~50
            DispatchQueue.main.async {
                completion(results)
            }
        }
        
        operation.resultsLimit = 50 // or however many you want
        publicDB.add(operation)
    }
}
