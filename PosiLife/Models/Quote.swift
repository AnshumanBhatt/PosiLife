//
//  Quote.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import Foundation

struct Quote: Identifiable, Codable, Hashable {
    let id = UUID()
    let text: String
    let author: String
    let category: Agenda
    let tags: [String]
    
    init(text: String, author: String, category: Agenda, tags: [String] = []) {
        self.text = text
        self.author = author
        self.category = category
        self.tags = tags
    }
}

enum Agenda: String, CaseIterable, Codable {
    case study = "Study"
    case job = "Job"
    case health = "Health"
    case motivation = "Motivation"
    case mindfulness = "Mindfulness"
    case success = "Success"
    case relationships = "Relationships"
    case creativity = "Creativity"
    case fitness = "Fitness"
    case general = "General"
    
    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .job: return "briefcase.fill"
        case .health: return "heart.fill"
        case .motivation: return "star.fill"
        case .mindfulness: return "leaf.fill"
        case .success: return "trophy.fill"
        case .relationships: return "person.2.fill"
        case .creativity: return "paintbrush.fill"
        case .fitness: return "figure.run"
        case .general: return "sparkles"
        }
    }
    
    var color: String {
        switch self {
        case .study: return "blue"
        case .job: return "purple"
        case .health: return "red"
        case .motivation: return "orange"
        case .mindfulness: return "green"
        case .success: return "yellow"
        case .relationships: return "pink"
        case .creativity: return "indigo"
        case .fitness: return "cyan"
        case .general: return "gray"
        }
    }
    
    var themeColors: [String] {
        switch self {
        case .study: return ["softBlue", "lightBlue", "paleBlue"]
        case .job: return ["lavender", "lightLavender", "paleLavender"]
        case .health: return ["rose", "lightRose", "paleRose"]
        case .motivation: return ["peach", "lightPeach", "palePeach"]
        case .mindfulness: return ["sage", "lightSage", "paleSage"]
        case .success: return ["gold", "lightGold", "paleGold"]
        case .relationships: return ["blushPink", "lightBlush", "paleBlush"]
        case .creativity: return ["lilac", "lightLilac", "paleLilac"]
        case .fitness: return ["aqua", "lightAqua", "paleAqua"]
        case .general: return ["softGray", "lightGray", "paleGray"]
        }
    }
}
