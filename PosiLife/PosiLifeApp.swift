//
//  PosiLifeApp.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI

@main
struct PosiLifeApp: App {
    @StateObject private var userSettings = UserSettings()
    @StateObject private var quoteManager = QuoteDataManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSettings)
                .environmentObject(quoteManager)
                .environmentObject(notificationManager)
                .onAppear {
                    // Initialize the app
                    setupInitialQuote()
                }
        }
    }
    
    private func setupInitialQuote() {
        quoteManager.setRandomCurrentQuote(for: userSettings.selectedAgenda)
        
        if userSettings.notificationsEnabled {
            notificationManager.scheduleWeeklyQuoteNotifications(
                for: userSettings,
                quotes: quoteManager.allQuotes
            )
        }
    }
}
