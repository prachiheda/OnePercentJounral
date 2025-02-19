//
//  JournalHistoryView.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import SwiftUI

struct JournalHistoryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @State private var searchText = ""
    @State private var selectedTimeFrame: TimeFrame = .all
    @State private var selectedTag: String?
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @State private var selectedEntry: JournalEntry?
    @State private var editedContent = ""
    @State private var showingEditSheet = false
    @AppStorage("userName") private var storedUserName = ""
    
    enum TimeFrame: String, CaseIterable {
        case all = "All Time"
        case week = "Past Week"
        case month = "Past Month"
        case year = "Past Year"
        case custom = "Custom Date"
    }
    
    var filteredEntries: [JournalEntry] {
        var filtered = viewModel.entries
        
        // Text search
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        }
        
        // Tag filter
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }
        
        // Time frame filter
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeFrame {
        case .week:
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
            filtered = filtered.filter { $0.date >= oneWeekAgo }
        case .month:
            let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
            filtered = filtered.filter { $0.date >= oneMonthAgo }
        case .year:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
            filtered = filtered.filter { $0.date >= oneYearAgo }
        case .custom:
            filtered = filtered.filter {
                calendar.isDate($0.date, inSameDayAs: selectedDate)
            }
        case .all:
            break
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var allTags: [String] {
        Array(Set(viewModel.entries.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("\(storedUserName)'s Journal History")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search entries", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Button(action: {
                                selectedTimeFrame = timeFrame
                                if timeFrame == .custom {
                                    showingDatePicker = true
                                }
                            }) {
                                Text(timeFrame.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedTimeFrame == timeFrame ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedTimeFrame == timeFrame ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                
                // Tag filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: { selectedTag = nil }) {
                            Text("All Tags")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTag == nil ? Color.blue : Color(.systemGray4))
                                .foregroundColor(selectedTag == nil ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: { selectedTag = tag }) {
                                Text(tag)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedTag == tag ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedTag == tag ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List(filteredEntries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.text)
                            .font(.system(.body, design: .serif))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack {
                            Text(entry.date, style: .date)
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Spacer()
                            
                            if !entry.tags.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.system(.caption, design: .serif))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(AppTheme.backgroundBlue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry = entry
                        editedContent = entry.text
                        showingEditSheet = true
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditSheet) {
                NavigationView {
                    VStack {
                        TextEditor(text: $editedContent)
                            .font(.system(size: 24, design: .serif))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding()
                            .background(AppTheme.backgroundBlue.opacity(0.3))
                            .cornerRadius(10)
                            .padding()
                        
                        Spacer()
                    }
                    .background(AppTheme.backgroundBlue.opacity(0.5).ignoresSafeArea())
                    .navigationTitle("Edit Entry")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingEditSheet = false
                            }
                            .foregroundColor(AppTheme.primaryBlue)
                            .font(.system(size: 17, design: .serif))
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                if let entry = selectedEntry {
                                    viewModel.updateEntry(entry, with: editedContent)
                                }
                                showingEditSheet = false
                            }
                            .foregroundColor(AppTheme.primaryBlue)
                            .font(.system(size: 17, design: .serif))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .navigationTitle("Select Date")
                    .navigationBarItems(trailing: Button("Done") {
                        showingDatePicker = false
                    })
                    .padding()
                }
            }
        }
    }
}

