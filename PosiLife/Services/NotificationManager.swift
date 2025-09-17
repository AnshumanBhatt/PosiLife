//
//  NotificationManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorization()
    }
    
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkAuthorization() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleQuoteNotifications(for settings: UserSettings, quotes: [Quote]) {
        // Remove existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Schedule notifications for the next 7 days
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            for (index, reminderTime) in settings.reminderTimes.enumerated() {
                let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
                var notificationDate = calendar.dateComponents([.year, .month, .day], from: targetDate)
                notificationDate.hour = components.hour
                notificationDate.minute = components.minute
                
                // Get a random quote for the current agenda
                let todayQuotes = quotes.filter { $0.category == settings.selectedAgenda }
                guard let randomQuote = todayQuotes.randomElement() else { continue }
                
                let content = UNMutableNotificationContent()
                content.title = "Daily Inspiration"
                content.body = randomQuote.text
                content.sound = .default
                content.badge = 1
                
                // Add quote data to userInfo for when notification is tapped
                content.userInfo = [
                    "quoteText": randomQuote.text,
                    "quoteAuthor": randomQuote.author,
                    "quoteCategory": randomQuote.category.rawValue
                ]
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
                let identifier = "quote_\(dayOffset)_\(index)"
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func scheduleWeeklyQuoteNotifications(for settings: UserSettings, quotes: [Quote]) {
        // Remove existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }
        
        // Schedule recurring daily notifications
        for (timeIndex, reminderTime) in settings.reminderTimes.enumerated() {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            // Get quotes for the selected agenda
            let agendaQuotes = quotes.filter { $0.category == settings.selectedAgenda }
            guard !agendaQuotes.isEmpty else { continue }
            
            // Create a repeating notification
            for dayOfWeek in 1...7 {
                var dateComponents = DateComponents()
                dateComponents.hour = components.hour
                dateComponents.minute = components.minute
                dateComponents.weekday = dayOfWeek
                
                let randomQuote = agendaQuotes.randomElement()!
                
                let content = UNMutableNotificationContent()
                content.title = "Daily Motivation"
                content.body = randomQuote.text
                content.sound = .default
                content.badge = 1
                
                content.userInfo = [
                    "quoteText": randomQuote.text,
                    "quoteAuthor": randomQuote.author,
                    "quoteCategory": randomQuote.category.rawValue,
                    "showFullScreen": true
                ]
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "recurring_quote_\(timeIndex)_\(dayOfWeek)"
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling recurring notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Post notification to open full screen quote
        if userInfo["showFullScreen"] != nil {
            NotificationCenter.default.post(
                name: NSNotification.Name("ShowFullScreenQuote"),
                object: nil,
                userInfo: userInfo
            )
        }
        
        completionHandler()
    }
}
