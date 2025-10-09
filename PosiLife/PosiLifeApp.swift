//
//  PosiLifeApp.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI
import FirebaseCore

@main
struct PosiLifeApp: App {
    @StateObject private var userSettings = UserSettings()
    @StateObject private var quoteManager = QuoteDataManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(userSettings)
                    .environmentObject(quoteManager)
                    .environmentObject(notificationManager)
                    .environmentObject(authManager)
                    .onAppear {
                        // Initialize the app
                        setupInitialQuote()
                    }
            } else {
                SignInView()
                    .environmentObject(authManager)
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
