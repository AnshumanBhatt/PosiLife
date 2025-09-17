//
//  Color+Theme.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI

extension Color {
    // MARK: - Peaceful Pink Theme Colors
    static let softPink = Color(red: 0.98, green: 0.85, blue: 0.87)
    static let lightPink = Color(red: 0.96, green: 0.80, blue: 0.83)
    static let blushPink = Color(red: 0.94, green: 0.75, blue: 0.79)
    static let pinkBackground = Color(red: 0.99, green: 0.95, blue: 0.96)
    
    // MARK: - Lavender/Purple Theme Colors
    static let lavender = Color(red: 0.90, green: 0.85, blue: 0.98)
    static let lightLavender = Color(red: 0.92, green: 0.88, blue: 0.99)
    static let paleLavender = Color(red: 0.95, green: 0.92, blue: 0.99)
    static let lightPurple = Color(red: 0.88, green: 0.82, blue: 0.96)
    static let purpleBackground = Color(red: 0.97, green: 0.95, blue: 0.99)
    
    // MARK: - Peaceful Mint/Green Colors
    static let softMint = Color(red: 0.85, green: 0.96, blue: 0.90)
    static let sage = Color(red: 0.82, green: 0.93, blue: 0.87)
    static let lightSage = Color(red: 0.88, green: 0.95, blue: 0.91)
    static let paleSage = Color(red: 0.92, green: 0.97, blue: 0.94)
    static let paleGreen = Color(red: 0.94, green: 0.98, blue: 0.95)
    static let peacefulBackground = Color(red: 0.96, green: 0.99, blue: 0.97)
    
    // MARK: - Agenda-Specific Peaceful Colors
    // Study (Soft Blue)
    static let softBlue = Color(red: 0.85, green: 0.92, blue: 0.98)
    static let lightBlue = Color(red: 0.90, green: 0.95, blue: 0.99)
    static let paleBlue = Color(red: 0.94, green: 0.97, blue: 0.99)
    
    // Health (Rose)
    static let rose = Color(red: 0.95, green: 0.82, blue: 0.85)
    static let lightRose = Color(red: 0.97, green: 0.87, blue: 0.89)
    static let paleRose = Color(red: 0.98, green: 0.92, blue: 0.93)
    
    // Motivation (Peach)
    static let peach = Color(red: 0.98, green: 0.88, blue: 0.82)
    static let lightPeach = Color(red: 0.99, green: 0.92, blue: 0.87)
    static let palePeach = Color(red: 0.99, green: 0.95, blue: 0.92)
    
    // Success (Gold)
    static let gold = Color(red: 0.96, green: 0.91, blue: 0.78)
    static let lightGold = Color(red: 0.98, green: 0.94, blue: 0.84)
    static let paleGold = Color(red: 0.99, green: 0.96, blue: 0.90)
    
    // Creativity (Lilac)
    static let lilac = Color(red: 0.93, green: 0.85, blue: 0.96)
    static let lightLilac = Color(red: 0.95, green: 0.89, blue: 0.97)
    static let paleLilac = Color(red: 0.97, green: 0.93, blue: 0.98)
    
    // Fitness (Aqua)
    static let aqua = Color(red: 0.82, green: 0.94, blue: 0.96)
    static let lightAqua = Color(red: 0.87, green: 0.96, blue: 0.97)
    static let paleAqua = Color(red: 0.92, green: 0.97, blue: 0.98)
    
    // General (Soft Gray)
    static let softGray = Color(red: 0.90, green: 0.90, blue: 0.92)
    static let lightGray = Color(red: 0.93, green: 0.93, blue: 0.94)
    static let paleGray = Color(red: 0.96, green: 0.96, blue: 0.97)
    
    // Relationships (Light Blush)
    static let lightBlush = Color(red: 0.96, green: 0.80, blue: 0.85)
    static let paleBlush = Color(red: 0.98, green: 0.88, blue: 0.91)
    
    // MARK: - Theme Color Resolver
    static func getThemeColor(for colorName: String, agenda: Agenda? = nil, theme: AppTheme = .serenePink) -> Color {
        // Handle adaptive colors for agenda-based theme
        if theme == .agendaBased, let agenda = agenda {
            switch colorName {
            case "adaptiveColor":
                return getThemeColor(for: agenda.color)
            case "adaptiveSecondary":
                return getThemeColor(for: agenda.themeColors[1])
            case "adaptiveBackground":
                return getThemeColor(for: agenda.themeColors[2])
            default:
                break
            }
        }
        
        switch colorName {
        // Basic colors
        case "pink": return .pink
        case "purple": return .purple
        case "mint": return .mint
        case "blue": return .blue
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "yellow": return .yellow
        case "indigo": return .indigo
        case "cyan": return .cyan
        case "gray": return .gray
        case "white": return .white
        case "black": return .black
        
        // Peaceful theme colors
        case "softPink": return .softPink
        case "lightPink": return .lightPink
        case "blushPink": return .blushPink
        case "pinkBackground": return .pinkBackground
        
        case "lavender": return .lavender
        case "lightLavender": return .lightLavender
        case "paleLavender": return .paleLavender
        case "lightPurple": return .lightPurple
        case "purpleBackground": return .purpleBackground
        
        case "softMint": return .softMint
        case "sage": return .sage
        case "lightSage": return .lightSage
        case "paleSage": return .paleSage
        case "paleGreen": return .paleGreen
        case "peacefulBackground": return .peacefulBackground
        
        // Agenda-specific colors
        case "softBlue": return .softBlue
        case "lightBlue": return .lightBlue
        case "paleBlue": return .paleBlue
        
        case "rose": return .rose
        case "lightRose": return .lightRose
        case "paleRose": return .paleRose
        
        case "peach": return .peach
        case "lightPeach": return .lightPeach
        case "palePeach": return .palePeach
        
        case "gold": return .gold
        case "lightGold": return .lightGold
        case "paleGold": return .paleGold
        
        case "lilac": return .lilac
        case "lightLilac": return .lightLilac
        case "paleLilac": return .paleLilac
        
        case "aqua": return .aqua
        case "lightAqua": return .lightAqua
        case "paleAqua": return .paleAqua
        
        case "softGray": return .softGray
        case "lightGray": return .lightGray
        case "paleGray": return .paleGray
        
        case "lightBlush": return .lightBlush
        case "paleBlush": return .paleBlush
        
        // Fallbacks
        default: return .primary
        }
    }
}
