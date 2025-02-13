//
//  JournalEntryView.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import SwiftUI

struct JournalEntryView: View {
    @State private var text: String = ""
    @State private var selectedTags: [String] = []
    @ObservedObject var viewModel: JournalViewModel
    @State private var showingTagInfo = false
    
    let emojiTags: [(emoji: String, description: String)] = [
        ("📚", "Career & Academics"),
        ("🌿", "Health & Wellness"),
        ("❤️", "Relationships"),
        ("🎨", "Creativity"),
        ("😊", "Personal Growth"),
        ("💪", "Physical Fitness")
    ]
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(dateFormatter.string(from: Date()))
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                if viewModel.isTestingMode {
                    HStack {
                        Text("(Testing Mode)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                        
                        Button(action: { viewModel.addMockData()}) {
                            Text("Clear All Entries")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                if !viewModel.canAddEntryToday() {
                    Text("You've already journaled today! Come back tomorrow for your next reflection.")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("To become 1% better today, I...")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $text)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Optional Tags:")
                                .font(.subheadline)
                            
                            Button(action: { showingTagInfo.toggle() }) {
                                Image(systemName: "info.circle")
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.customTags) { tag in
                                    TagButton(
                                        emoji: tag.emoji,
                                        isSelected: selectedTags.contains(tag.emoji),
                                        action: {
                                            if selectedTags.contains(tag.emoji) {
                                                selectedTags.removeAll { $0 == tag.emoji }
                                            } else {
                                                selectedTags.append(tag.emoji)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            viewModel.addEntry(text: text, tags: selectedTags)
                            text = ""
                            selectedTags = []
                        }) {
                            Text("Save Entry")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingTagInfo) {
            TagInfoView(viewModel: viewModel)
        }
    }
}

struct TagButton: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.title)
                .padding(10)
                .background(isSelected ? Color.blue.opacity(0.3) : Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

struct TagInfoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @State private var showingAddTag = false
    @State private var editingTag: JournalViewModel.CustomTag? = nil
    @State private var editingIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Personalize your journal with custom tags! Swipe left to remove a tag, or tap the pencil to edit.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                
                List {
                    ForEach(viewModel.customTags.indices, id: \.self) { index in
                        let tag = viewModel.customTags[index]
                        HStack {
                            Text(tag.emoji)
                                .font(.title)
                            Text(tag.description)
                                .font(.body)
                            Spacer()
                            Button(action: {
                                editingTag = tag
                                editingIndex = index
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { viewModel.removeTag(at: $0) }
                    }
                }
            }
            .navigationTitle("Custom Tags")
            .navigationBarItems(
                leading: Button("Done") { dismiss() },
                trailing: Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddTag) {
                TagEditView(viewModel: viewModel)
            }
            .sheet(item: $editingTag) { tag in
                TagEditView(
                    viewModel: viewModel,
                    editingIndex: editingIndex,
                    initialEmoji: tag.emoji,
                    initialDescription: tag.description
                )
            }
        }
    }
}

struct TagEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    var editingIndex: Int?
    
    @State private var emoji: String
    @State private var description: String
    
    init(viewModel: JournalViewModel, editingIndex: Int? = nil, initialEmoji: String = "", initialDescription: String = "") {
        self.viewModel = viewModel
        self.editingIndex = editingIndex
        _emoji = State(initialValue: initialEmoji)
        _description = State(initialValue: initialDescription)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Emoji", text: $emoji)
                TextField("Description", text: $description)
            }
            .navigationTitle(editingIndex == nil ? "Add Tag" : "Edit Tag")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let index = editingIndex {
                        viewModel.updateTag(at: index, emoji: emoji, description: description)
                    } else {
                        viewModel.addCustomTag(emoji: emoji, description: description)
                    }
                    dismiss()
                }
                .disabled(emoji.isEmpty || description.isEmpty)
            )
        }
    }
}

