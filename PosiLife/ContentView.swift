//
//  ContentView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var quoteManager: QuoteDataManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var showingSettings = false
    
    @State private var selectedQuoteForFullScreen: Quote?
    
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab: Tab = .home
    
    enum Tab {
           case home, profile
       }
    
    var body: some View {
        
        
        TabView(selection: $selectedTab ) {
            NavigationStack( path: $navigationPath) {
                ZStack {
                    // Background gradient based on theme
                    LinearGradient(
                        gradient: Gradient(colors: [getThemeColor(userSettings.selectedTheme.primaryColor), getThemeColor(userSettings.selectedTheme.secondaryColor)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .opacity(0.1)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Header
                            headerView
                            
                            // Current Quote Card
                            currentQuoteCard
                            
                            // Agenda Progress
                            agendaProgressCard
                            
                            // Quick Actions
                            quickActionsView
                            
                            // Extra Utility
                            utilityButtons
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
                .navigationBarHidden(true)
                .navigationDestination(for: String.self) {
                    destination in
                    
                    switch destination {
                    case "history":
                        HistoryView()
                    case "settings":
                        SettingsView(userSettings: userSettings, notificationManager: notificationManager, quoteManager: quoteManager)
                    default:
                        EmptyView()
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)
            
            NavigationStack {
                ProfileView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            
            .tabItem{
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(Tab.profile)
            
            
            .fullScreenCover(isPresented: Binding (
                get: {selectedQuoteForFullScreen != nil},
                set: { if !$0 {selectedQuoteForFullScreen = nil}}
            )) {
                if let quote = selectedQuoteForFullScreen {
                    FullScreenQuoteView(quote: quote, isPresented: Binding (get:{selectedQuoteForFullScreen != nil}, set: { if  !$0 {selectedQuoteForFullScreen = nil }}), theme: userSettings.selectedTheme)
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowFullScreenQuote"))) { notification in
                if let userInfo = notification.userInfo,
                   let quoteText = userInfo["quoteText"] as? String,
                   let quoteAuthor = userInfo["quoteAuthor"] as? String,
                   let categoryString = userInfo["quoteCategory"] as? String,
                   let category = Agenda(rawValue: categoryString) {
                    selectedQuoteForFullScreen = Quote(text: quoteText, author: quoteAuthor, category: category)
                }
            }
            .onAppear {
                setupInitialState()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(getGreeting())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Let's start your day with positivity!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { navigationPath.append("settings") }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Circle().fill(Color(UIColor.systemGray5)))
            }
        }
    }
    
    private var currentQuoteCard: some View {
        VStack(spacing: 16) {
            if let currentQuote = quoteManager.currentQuote {
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: currentQuote.category.icon)
                                .font(.title2)
                                .foregroundColor(getThemeColor(currentQuote.category.color))
                                .symbolRenderingMode(.monochrome)
                                
                            
                            Text(currentQuote.category.rawValue)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(getThemeColor(currentQuote.category.color))
                                
                        }
                        
                        Spacer()
                        
                        Button(action:  {
                            
                            selectedQuoteForFullScreen = currentQuote
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.caption)
                                .foregroundColor(.primary.opacity(0.7))
                        }
                    }
                    
                    Text(currentQuote.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                    
                    Text("— \(currentQuote.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            } else {
                Text("Loading inspiration...")
                    .font(.title3)
                    .foregroundColor(getThemeColor(userSettings.selectedTheme.primaryColor).opacity(0.9))
            }
            
            Button(action: {
                quoteManager.setRandomCurrentQuote(for: userSettings.selectedAgenda)
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("New Quote")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color(UIColor.systemGray6)))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var agendaProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: userSettings.selectedAgenda.icon)
                    .font(.title2)
                    .foregroundColor(getThemeColor(userSettings.selectedAgenda.color))
                    .symbolRenderingMode(.monochrome)
                
                Text("Current Focus: \(userSettings.selectedAgenda.rawValue)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            let daysElapsed = Calendar.current.dateComponents([.day], from: userSettings.agendaStartDate, to: Date()).day ?? 0
            let progress = min(Double(daysElapsed) / Double(userSettings.agendaDuration), 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .foregroundColor(getThemeColor(userSettings.selectedAgenda.color))
                    
                    Spacer()
                    
                    Text("\(daysElapsed)/\(userSettings.agendaDuration) days")
                        .font(.caption)
                        .foregroundColor(getThemeColor(userSettings.selectedAgenda.color))
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: getThemeColor(userSettings.selectedAgenda.color)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
    }
    
    private var quickActionsView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            QuickActionButton(
                icon: "bell.fill",
                title: "Reminders",
                subtitle: "\(userSettings.reminderTimes.count) active",
                color: getThemeColor("orange"),
                action: { navigationPath.append("settings")}
            )
            
            QuickActionButton(
                icon: "paintbrush.fill",
                title: "Themes",
                subtitle: userSettings.selectedTheme.rawValue,
                color: getThemeColor("purple"),
                action: { navigationPath.append("settings") }
            )
        }
    }
    private var utilityButtons: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            QuickActionButton(
                icon: "clock.fill",
                title: "History",
                subtitle: "\(userSettings.reminderTimes.count) active",
                color: getThemeColor("cyan"),
                action: { navigationPath.append("history") }
            )
            
            QuickActionButton(
                icon: "plus",
                title: "More",
                subtitle: userSettings.selectedTheme.rawValue,
                color: getThemeColor("purple"),
                action: { navigationPath.append("settings") }
            )
        }
    }
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, agenda: userSettings.selectedAgenda, theme: userSettings.selectedTheme)
    }
    
    private func setupInitialState() {
        if !notificationManager.isAuthorized {
            notificationManager.requestPermission()
        }
        
        quoteManager.setRandomCurrentQuote(for: userSettings.selectedAgenda)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(color.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
        .environmentObject(NotificationManager())
        .environmentObject(QuoteDataManager())
        
}
