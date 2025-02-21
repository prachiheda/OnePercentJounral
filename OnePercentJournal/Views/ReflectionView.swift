//  ReflectionView.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import SwiftUI

struct ReflectionView: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Your Growth Journey")
                    .font(.custom("HelveticaNeue-Bold", size: 35))
                    .bold()
                    .foregroundColor(AppTheme.textPrimaryDark) // Use deep navy color
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Time-based Reflections
                VStack(spacing: 12) {
                    ReflectionSection(title: "1 Week Ago", entries: filterEntries(daysAgo: 7))
                        .foregroundColor(AppTheme.textPrimaryDark)
                    Divider()
                        .padding(.vertical, 8)
                    ReflectionSection(title: "1 Month Ago", entries: filterEntries(daysAgo: 30))
                        .foregroundColor(AppTheme.textPrimaryDark)
                    Divider()
                        .padding(.vertical, 8)
                    ReflectionSection(title: "1 Year Ago", entries: filterEntries(daysAgo: 365))
                        .foregroundColor(AppTheme.textPrimaryDark)
                }
                .padding(16)
                .background(AppTheme.cardBackground) // Use a soft warm white for card background
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .background(AppTheme.backgroundBlue) // Apply cozy background
    }
    
    private func filterEntries(daysAgo: Int) -> [JournalEntry] {
        let calendar = Calendar.current
        let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        
        // Create a range of ±1 day around the target date
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: targetDate) ?? targetDate
        let dayAfter = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
        
        return viewModel.entries.filter { entry in
            let entryDate = calendar.startOfDay(for: entry.date)
            return entryDate >= calendar.startOfDay(for: dayBefore) &&
                   entryDate <= calendar.startOfDay(for: dayAfter)
        }
    }
}

struct ReflectionSection: View {
    let title: String
    let entries: [JournalEntry]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Title (Always Left-Aligned)
            Text(title)
                .font(.custom("HelveticaNeue-Bold", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if entries.isEmpty {
                // Consistently Left-Aligned Empty Message
                Text("No entry found for this day")
                    .font(.custom("HelveticaNeue", size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Entry List with Consistent Alignment
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        // Date Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateFormatter.string(from: entry.date))
                                .font(.custom("HelveticaNeue", size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Entry Text
                        Text(entry.text)
                            .font(.custom("HelveticaNeue", size: 20))
                            .foregroundColor(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Tags
                        if !entry.tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.custom("HelveticaNeue", size: 12))
                                        .foregroundColor(AppTheme.textPrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Enforces left alignment for the entire section
    }
}


struct ReflectionView_Previews: PreviewProvider {
    static var previews: some View {
        // 1) Create a sample JournalViewModel.
        let sampleViewModel = JournalViewModel()
        
        // 3) Return the view for previews.
        return ReflectionView(viewModel: sampleViewModel)
    }
}
