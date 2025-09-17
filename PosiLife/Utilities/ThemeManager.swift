//
//  ThemeManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .serenePink
    @Published var currentAgenda: Agenda = .general
    
    init(userSettings: UserSettings) {
        self.currentTheme = userSettings.selectedTheme
        self.currentAgenda = userSettings.selectedAgenda
        
        // Listen for changes in user settings
        userSettings.$selectedTheme
            .assign(to: &$currentTheme)
        
        userSettings.$selectedAgenda
            .assign(to: &$currentAgenda)
    }
    
    /// Get a themed color based on current theme and agenda
    func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, agenda: currentAgenda, theme: currentTheme)
            .opacity(1.0)
    }
    
    /// Get primary color for current theme
    var primaryColor: Color {
        return getThemeColor(currentTheme.primaryColor)
    }
    
    /// Get secondary color for current theme
    var secondaryColor: Color {
        return getThemeColor(currentTheme.secondaryColor)
    }
    
    /// Get background color for current theme
    var backgroundColor: Color {
        return getThemeColor(currentTheme.backgroundColor)
    }
    
    /// Get gradient colors for current theme
    var gradientColors: [Color] {
        return currentTheme.gradientColors.map { getThemeColor($0) }
    }
    
    /// Get agenda-specific color
    func getAgendaColor(_ agenda: Agenda) -> Color {
        return getThemeColor(agenda.color)
    }
    
    /// Get current agenda color
    var currentAgendaColor: Color {
        return getAgendaColor(currentAgenda)
    }
}

// MARK: - SwiftUI Environment Key
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager(userSettings: UserSettings())
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Extension for Themed Colors
extension View {
    func themedForeground(_ colorName: String) -> some View {
        self.modifier(ThemedForegroundModifier(colorName: colorName))
    }
    
    func themedBackground(_ colorName: String) -> some View {
        self.modifier(ThemedBackgroundModifier(colorName: colorName))
    }
}

struct ThemedForegroundModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    let colorName: String
    
    func body(content: Content) -> some View {
        content.foregroundColor(themeManager.getThemeColor(colorName))
    }
}

struct ThemedBackgroundModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    let colorName: String
    
    func body(content: Content) -> some View {
        content.background(themeManager.getThemeColor(colorName))
    }
}
