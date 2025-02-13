//
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
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Time-based Reflections
                VStack(spacing: 12) {
                    ReflectionSection(title: "1 Week Ago", entries: filterEntries(daysAgo: 7))
                    Divider()
                        .padding(.vertical, 8)
                    ReflectionSection(title: "1 Month Ago", entries: filterEntries(daysAgo: 30))
                    Divider()
                        .padding(.vertical, 8)
                    ReflectionSection(title: "1 Year Ago", entries: filterEntries(daysAgo: 365))
                }
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
        }
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
            if entries.isEmpty {
                Text(title)
                    .font(.headline)
                Text("No entry found for this day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
            } else {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.headline)
                            Text(dateFormatter.string(from: entry.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(entry.text)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Spacer()
                            
                            if !entry.tags.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

