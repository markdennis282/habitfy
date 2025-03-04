//
//  MyServerLeaderboardService.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//

import SwiftUI// MyServerLeaderboardService.swift
import Foundation

class MyServerLeaderboardService: LeaderboardServiceProtocol {
    
    // Replace with your actual endpoint base URL
    private let baseURL = URL(string: "https://myawesomebackend.com/api")!
    
    func fetchLeaderboard(completion: @escaping (Result<[Friend], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("leaderboard")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(MyServerError.noData))
                return
            }
            do {
                let friends = try JSONDecoder().decode([Friend].self, from: data)
                // Optionally sort here or let the server sort
                completion(.success(friends))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("leaderboard/update")
        
        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let bodyData = try JSONEncoder().encode(friend)
            request.httpBody = bodyData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}

// For clarity, define a custom error if needed
enum MyServerError: Error {
    case noData
}

