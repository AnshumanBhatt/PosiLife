//
//  HistoryView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 17/09/25.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    getThemeColor(userSettings.selectedTheme.primaryColor),
                    getThemeColor(userSettings.selectedTheme.secondaryColor)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(0.1)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Statistics Card
                    statisticsCard
                    
                    // Pie Chart Card
                    if !viewModel.completedGoals.isEmpty {
                        pieChartCard
                    }
                    
                    // Completed Goals List
                    completedGoalsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var statisticsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Goals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.completedGoals.count)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(totalDays)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quotes Received")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(totalQuotes)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(getThemeColor(userSettings.selectedTheme.primaryColor))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Most Focused")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let mostFocused = mostFocusedAgenda {
                        HStack(spacing: 6) {
                            Image(systemName: mostFocused.icon)
                                .font(.caption)
                            Text(mostFocused.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(getThemeColor(mostFocused.color))
                    } else {
                        Text("—")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var pieChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Focus Distribution")
                .font(.headline)
                .foregroundColor(.primary)
            
            let agendaCounts = viewModel.getAgendaCounts()
            
            if #available(iOS 16.0, *) {
                Chart(agendaCounts.sorted(by: { $0.value > $1.value }), id: \.key) { agenda, count in
                    SectorMark(
                        angle: .value("Count", count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(getThemeColor(agenda.color))
                    .annotation(position: .overlay) {
                        if count > 0 {
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 250)
                .chartBackground { _ in
                    Text("Goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(agendaCounts.sorted(by: { $0.value > $1.value }), id: \.key) { agenda, count in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(getThemeColor(agenda.color))
                                .frame(width: 12, height: 12)
                            
                            Text(agenda.rawValue)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            } else {
                // Fallback for iOS 15
                VStack(spacing: 12) {
                    ForEach(agendaCounts.sorted(by: { $0.value > $1.value }), id: \.key) { agenda, count in
                        HStack {
                            Circle()
                                .fill(getThemeColor(agenda.color))
                                .frame(width: 12, height: 12)
                            
                            Text(agenda.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(count) goals")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var completedGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completed Goals")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            if viewModel.completedGoals.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.completedGoals.sorted(by: { $0.endDate > $1.endDate })) { goal in
                    CompletedGoalCard(goal: goal)
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = viewModel.completedGoals.firstIndex(where: { $0.id == goal.id }) {
                                    viewModel.deleteGoals(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Completed Goals Yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Complete your first goal to see it here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var totalDays: Int {
        viewModel.completedGoals.reduce(0) { $0 + $1.duration }
    }
    
    private var totalQuotes: Int {
        viewModel.completedGoals.reduce(0) { $0 + $1.quotesReceived }
    }
    
    private var mostFocusedAgenda: Agenda? {
        let counts = viewModel.getAgendaCounts()
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, agenda: userSettings.selectedAgenda, theme: userSettings.selectedTheme)
    }
}

struct CompletedGoalCard: View {
    let goal: CompletedGoals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: goal.agenda.icon)
                        .font(.title3)
                        .foregroundColor(Color.getThemeColor(for: goal.agenda.color))
                    
                    Text(goal.agenda.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(goal.duration) days")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Quotes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(goal.quotesReceived)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            HStack(spacing: 4) {
                Text(formatDate(goal.startDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(formatDate(goal.endDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(UserSettings())
    }
}
