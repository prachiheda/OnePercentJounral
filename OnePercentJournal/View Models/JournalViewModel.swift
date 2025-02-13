//
//  JournalViewModel.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import Foundation

class JournalViewModel: ObservableObject {
    struct CustomTag: Codable, Identifiable {
        let id: UUID
        var emoji: String
        var description: String
    }
    
    @Published var entries: [JournalEntry] = []
    @Published var customTags: [CustomTag] = []
    @Published var isTestingMode: Bool = false // For Swift Student Challenge testing
    
    private let userDefaultsKey = "journalEntries"
    private let tagsDefaultsKey = "customTags"

    init() {
        loadEntries()
        loadTags()
        if entries.isEmpty && isTestingMode {
            addMockData()
        }
        if customTags.isEmpty {
            // Default tags
            customTags = [
                CustomTag(id: UUID(), emoji: "📚", description: "Career & Academics"),
                CustomTag(id: UUID(), emoji: "🌿", description: "Health & Wellness"),
                CustomTag(id: UUID(), emoji: "❤️", description: "Relationships"),
                CustomTag(id: UUID(), emoji: "🎨", description: "Creativity"),
                CustomTag(id: UUID(), emoji: "😊", description: "Personal Growth"),
                CustomTag(id: UUID(), emoji: "💪", description: "Physical Fitness")
            ]
            saveTags()
        }
    }
    
    func addCustomTag(emoji: String, description: String) {
        let newTag = CustomTag(id: UUID(), emoji: emoji, description: description)
        customTags.append(newTag)
        saveTags()
    }
    
    func removeTag(at index: Int) {
        customTags.remove(at: index)
        saveTags()
    }
    
    func updateTag(at index: Int, emoji: String, description: String) {
        customTags[index].emoji = emoji
        customTags[index].description = description
        saveTags()
    }
    
    private func loadTags() {
        if let data = UserDefaults.standard.data(forKey: tagsDefaultsKey),
           let savedTags = try? JSONDecoder().decode([CustomTag].self, from: data) {
            self.customTags = savedTags
        }
    }
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(customTags) {
            UserDefaults.standard.set(encoded, forKey: tagsDefaultsKey)
        }
    }

    func clearAllEntries() {
        entries = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    func addMockData() {
    // Clear existing entries first
        clearAllEntries()
        
        // One week ago
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekEntry = JournalEntry(id: UUID(), date: oneWeekAgo, text: "To become 1% better today, I took a long walk in nature and practiced mindfulness", tags: ["🌿"])
        
        // One month ago
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let monthEntry = JournalEntry(id: UUID(), date: oneMonthAgo, text: "To become 1% better today, I helped my friend move and strengthened our friendship", tags: ["❤️"])
        
        // One year ago
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let yearEntry = JournalEntry(id: UUID(), date: oneYearAgo, text: "To become 1% better today, I finished reading a challenging book about quantum physics", tags: ["📚"])
        
        entries = [weekEntry, monthEntry, yearEntry]
        saveEntries()
    }

    func canAddEntryToday() -> Bool {
        if isTestingMode { return true } // Always allow entries in testing mode
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return !entries.contains { entry in
            calendar.isDate(calendar.startOfDay(for: entry.date), inSameDayAs: today)
        }
    }

    func addEntry(text: String, tags: [String]) {
        guard canAddEntryToday() else { return }
        let fullText = "To become 1% better today, I " + text
        let newEntry = JournalEntry(id: UUID(), date: Date(), text: fullText, tags: tags)
        entries.append(newEntry)
        saveEntries()
    }
    
    func addEntry(_ entry: JournalEntry){
        entries.append(entry)
        saveEntries()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedEntries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            self.entries = savedEntries
        }
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

