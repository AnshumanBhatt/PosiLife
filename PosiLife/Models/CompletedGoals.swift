//
//  CompletedGoals.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 29/09/25.
//

import Foundation

struct CompletedGoals: Identifiable, Codable {
    let id: UUID
    let agenda: Agenda
    let startDate: Date
    let endDate: Date
    let duration: Int
    let quotesReceived: Int

    // Backward-compatibility for previously persisted key "quotesRecieved"
    enum CodingKeys: String, CodingKey {
        case id, agenda, startDate, endDate, duration
        case quotesReceived = "quotesRecieved"
    }

    init(id: UUID = UUID(), agenda: Agenda, startDate: Date, endDate: Date, duration: Int, quotesReceived: Int) {
        self.id = id
        self.agenda = agenda
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.quotesReceived = quotesReceived
    }
}

