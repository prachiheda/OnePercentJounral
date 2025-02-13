//
//  JournalEntry.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var text: String
    var tags: [String]  // Emojis as strings
}

