//
//  HistoryManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 29/09/25.
//

import Foundation

// Concrete repository implementation that persists to UserDefaults
final class UserDefaultsHistoryRepository: HistoryRepository {
    private let userDefaultsKey = "completedGoals"

    func loadCompletedGoals() -> [CompletedGoals] {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([CompletedGoals].self, from: data) {
            return decoded
        }
        return []
    }

    func saveCompletedGoals(_ goals: [CompletedGoals]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
