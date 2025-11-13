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
                ContentViewWrapper(userSettings: userSettings)
                    .environmentObject(userSettings)
                    .environmentObject(quoteManager)
                    .environmentObject(notificationManager)
                    .environmentObject(authManager)
                    .onAppear {
                        // Initialize the app
                        setupInitialQuote()
                    }
            } else {
                SignInViewWrapper(userSettings: userSettings)
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

// MARK: - Wrapper Views for ThemeManager Injection

struct ContentViewWrapper: View {
    @ObservedObject var userSettings: UserSettings
    @StateObject private var themeManager: ThemeManager
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        _themeManager = StateObject(wrappedValue: ThemeManager(userSettings: userSettings))
    }
    
    var body: some View {
        ContentView()
            .environmentObject(themeManager)
    }
}

struct SignInViewWrapper: View {
    @ObservedObject var userSettings: UserSettings
    @StateObject private var themeManager: ThemeManager
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        _themeManager = StateObject(wrappedValue: ThemeManager(userSettings: userSettings))
    }
    
    var body: some View {
        SignInView()
            .environmentObject(themeManager)
    }
}
