//
//  SettingsView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var quoteManager: QuoteDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var newReminderTime = Date()
    @State private var showingAgendaPicker = false
    @State private var showingThemePicker = false
    
    init(userSettings: UserSettings, notificationManager: NotificationManager, quoteManager: QuoteDataManager) {
        self.userSettings = userSettings
        self.notificationManager = notificationManager
        self.quoteManager = quoteManager
    }
    
    var body: some View {
        
            Form {
                notificationSection
                agendaSection
                appearanceSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        
    }
    
    private var notificationSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Enable Notifications", isOn: $userSettings.notificationsEnabled)
                .onChange(of: userSettings.notificationsEnabled) { enabled in
                    if enabled {
                        notificationManager.requestPermission()
                    } else {
                        notificationManager.cancelAllNotifications()
                    }
                }
            
            if userSettings.notificationsEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reminder Times")
                        .font(.headline)
                }
                
                ForEach(0..<userSettings.reminderTimes.count, id: \.self) { index in
                    HStack {
                        DatePicker(
                            "Reminder \(index + 1)",
                            selection: Binding(
                                get: { 
                                    guard index < userSettings.reminderTimes.count else { return Date() }
                                    return userSettings.reminderTimes[index] 
                                },
                                set: { 
                                    guard index < userSettings.reminderTimes.count else { return }
                                    userSettings.reminderTimes[index] = $0 
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        
                        if userSettings.reminderTimes.count > 1 {
                            Button("Remove") {
                                if index < userSettings.reminderTimes.count {
                                    userSettings.reminderTimes.remove(at: index)
                                }
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                }
                
                if userSettings.reminderTimes.count < 5 {
                    Button("Add Reminder") {
                        userSettings.reminderTimes.append(newReminderTime)
                    }
                    .foregroundColor(.blue)
                }
                
                Stepper(
                    "Quotes per day: \(userSettings.quotesPerDay)",
                    value: $userSettings.quotesPerDay,
                    in: 1...10
                )
            }
        }
    }
    
    private var agendaSection: some View {
        Section(header: Text("Current Focus")) {
            NavigationLink(destination: AgendaPickerView(
                selectedAgenda: $userSettings.selectedAgenda,
                isPresented: .constant(false),
                onSave: {
                    quoteManager.setRandomCurrentQuote(for: userSettings.selectedAgenda)
                    userSettings.saveSettings()
                }
            )) {
                HStack {
                    Image(systemName: userSettings.selectedAgenda.icon)
                        .foregroundColor(getThemeColor(userSettings.selectedAgenda.color))
                    
                    VStack(alignment: .leading) {
                        Text("Agenda")
                            .foregroundColor(.primary)
                        Text(userSettings.selectedAgenda.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            DatePicker(
                "Start Date",
                selection: $userSettings.agendaStartDate,
                displayedComponents: .date
            )
            
            Stepper(
                "Duration: \(userSettings.agendaDuration) days",
                value: $userSettings.agendaDuration,
                in: 7...365,
                step: 7
            )
            
            let daysElapsed = Calendar.current.dateComponents([.day], from: userSettings.agendaStartDate, to: Date()).day ?? 0
            let progress = min(Double(daysElapsed) / Double(userSettings.agendaDuration), 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(daysElapsed)/\(userSettings.agendaDuration) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: getThemeColor(userSettings.selectedAgenda.color)))
            }
        }
    }
    
    private var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            Button(action: { showingThemePicker = true }) {
                HStack {
                    Circle()
                        .fill(getThemeColor(userSettings.selectedTheme.primaryColor))
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading) {
                        Text("Theme")
                            .foregroundColor(.primary)
                        Text(userSettings.selectedTheme.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView(
                selectedTheme: $userSettings.selectedTheme,
                isPresented: $showingThemePicker
            )
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Total Quotes")
                Spacer()
                Text("\(quoteManager.allQuotes.count)")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, agenda: userSettings.selectedAgenda, theme: userSettings.selectedTheme)
    }
    
    private func saveSettings() {
        userSettings.saveSettings()
        
        if userSettings.notificationsEnabled {
            notificationManager.scheduleWeeklyQuoteNotifications(
                for: userSettings,
                quotes: quoteManager.allQuotes
            )
        }
    }
}

struct AgendaPickerView: View {
    @Binding var selectedAgenda: Agenda
    @Binding var isPresented: Bool
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(Agenda.allCases, id: \.self) { agenda in
                HStack {
                    Image(systemName: agenda.icon)
                        .font(.title2)
                        .foregroundColor(getThemeColor(agenda.color))
                        .frame(width: 30)
                    
                    Text(agenda.rawValue)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedAgenda == agenda {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAgenda = agenda
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Select Focus Area")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName)
    }
}

struct ThemePickerView: View {
    @Binding var selectedTheme: AppTheme
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: selectedTheme == theme,
                        action: {
                            selectedTheme = theme
                            isPresented = false
                        }
                    )
                }
            }
            .padding()
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                getThemeColor(theme.primaryColor),
                                getThemeColor(theme.secondaryColor)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                Text(theme.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName)
    }
}

#Preview {
    SettingsView(
        userSettings: UserSettings(),
        notificationManager: NotificationManager(),
        quoteManager: QuoteDataManager()
    )
}
