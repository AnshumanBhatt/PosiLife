//
//  HistoryViewModel.swift
//  PosiLife
//
//  MVVM ViewModel for History screen following SOLID.
//

import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    @Published private(set) var completedGoals: [CompletedGoals] = []

    private let repository: HistoryRepository

    init(repository: HistoryRepository = UserDefaultsHistoryRepository()) {
        self.repository = repository
        load()
    }

    func load() {
        completedGoals = repository.loadCompletedGoals()
    }

    func addCompletedGoal(_ goal: CompletedGoals) {
        completedGoals.append(goal)
        persist()
    }

    func deleteGoals(at offsets: IndexSet) {
        completedGoals.remove(atOffsets: offsets)
        persist()
    }

    func getAgendaCounts() -> [Agenda: Int] {
        var counts: [Agenda: Int] = [:]
        for goal in completedGoals { counts[goal.agenda, default: 0] += 1 }
        return counts
    }

    private func persist() {
        repository.saveCompletedGoals(completedGoals)
    }
}
