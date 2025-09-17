//
//  UserSettings.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var selectedAgenda: Agenda = .general
    @Published var agendaStartDate: Date = Date()
    @Published var agendaDuration: Int = 60 // days
    @Published var reminderTimes: [Date] = [Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()]
    @Published var quotesPerDay: Int = 3
    @Published var selectedTheme: AppTheme = .serenePink
    @Published var notificationsEnabled: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(selectedAgenda) {
            userDefaults.set(encoded, forKey: "selectedAgenda")
        }
        
        userDefaults.set(agendaStartDate, forKey: "agendaStartDate")
        userDefaults.set(agendaDuration, forKey: "agendaDuration")
        
        if let encoded = try? JSONEncoder().encode(reminderTimes) {
            userDefaults.set(encoded, forKey: "reminderTimes")
        }
        
        userDefaults.set(quotesPerDay, forKey: "quotesPerDay")
        
        if let encoded = try? JSONEncoder().encode(selectedTheme) {
            userDefaults.set(encoded, forKey: "selectedTheme")
        }
        
        userDefaults.set(notificationsEnabled, forKey: "notificationsEnabled")
    }
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: "selectedAgenda"),
           let agenda = try? JSONDecoder().decode(Agenda.self, from: data) {
            selectedAgenda = agenda
        }
        
        if let date = userDefaults.object(forKey: "agendaStartDate") as? Date {
            agendaStartDate = date
        }
        
        agendaDuration = userDefaults.object(forKey: "agendaDuration") as? Int ?? 60
        
        if let data = userDefaults.data(forKey: "reminderTimes"),
           let times = try? JSONDecoder().decode([Date].self, from: data) {
            reminderTimes = times
        }
        
        quotesPerDay = userDefaults.object(forKey: "quotesPerDay") as? Int ?? 3
        
        if let data = userDefaults.data(forKey: "selectedTheme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            selectedTheme = theme
        }
        
        notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
    }
}

enum AppTheme: String, CaseIterable, Codable {
    case serenePink = "Serene Pink"
    case lavenderDream = "Lavender Dream"
    case peaceful = "Peaceful"
    case agendaBased = "Agenda Based"
    
    var primaryColor: String {
        switch self {
        case .serenePink: return "softPink"
        case .lavenderDream: return "lavender"
        case .peaceful: return "sage"
        case .agendaBased: return "adaptiveColor" // This will be handled dynamically
        }
    }
    
    var backgroundColor: String {
        switch self {
        case .serenePink: return "pinkBackground"
        case .lavenderDream: return "purpleBackground"
        case .peaceful: return "peacefulBackground"
        case .agendaBased: return "adaptiveBackground"
        }
    }
    
    var secondaryColor: String {
        switch self {
        case .serenePink: return "lightPink"
        case .lavenderDream: return "lightLavender"
        case .peaceful: return "lightSage"
        case .agendaBased: return "adaptiveSecondary"
        }
    }
    
    var gradientColors: [String] {
        switch self {
        case .serenePink: return ["softPink", "lightPink", "pinkBackground"]
        case .lavenderDream: return ["lavender", "lightLavender", "paleLavender"]
        case .peaceful: return ["sage", "lightSage", "paleGreen"]
        case .agendaBased: return ["adaptiveColor", "adaptiveSecondary"]
        }
    }
}
