//
//  HistoryRepository.swift
//  PosiLife
//
//  Defines the repository abstraction for completed goals history.
//

import Foundation

protocol HistoryRepository {
    func loadCompletedGoals() -> [CompletedGoals]
    func saveCompletedGoals(_ goals: [CompletedGoals])
}
