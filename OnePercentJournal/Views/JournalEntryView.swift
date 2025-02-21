import SwiftUI

struct JournalEntryView: View {
    @State private var text: String = ""
    @State private var selectedTags: [String] = []
    @ObservedObject var viewModel: JournalViewModel
    @State private var showingTagInfo = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        ZStack {
            // Use the same background as your onboarding.
            AppTheme.backgroundBlue.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date title styled similarly to your onboarding header.
                    Text(dateFormatter.string(from: Date()))
                        .font(.custom("HelveticaNeue-Bold", size: 40))
                        .foregroundColor(AppTheme.textPrimaryDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if viewModel.isTestingMode {
                        HStack {
                            Text("(Testing Mode)")
                                .font(.custom("HelveticaNeue-Bold", size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primaryBlue.opacity(0.2))
                                .foregroundColor(AppTheme.primaryBlue)
                                .cornerRadius(8)
                            
                            Button(action: { viewModel.addMockData() }) {
                                Text("Clear All Entries")
                                    .font(.custom("HelveticaNeue-Bold", size: 14))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.primaryBlue.opacity(0.2))
                                    .foregroundColor(AppTheme.primaryBlue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if !viewModel.canAddEntryToday() {
                        Text("You've already journaled today! Come back tomorrow for your next reflection.")
                            .font(.custom("HelveticaNeue", size: 20))
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            // Prompt styled to match your onboarding text.
                            Text("To become 1% better today, I...")
                                .font(.custom("HelveticaNeue", size: 30))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal)
                            
                            // Journal entry editor with matching background and border.
                            TextEditor(text: $text)
                                .font(.custom("HelveticaNeue", size: 24))

                                .background(AppTheme.primaryBlue.opacity(0.1))
                                .cornerRadius(10)
                                .frame(height: 200)
        
                                .padding(.horizontal)
                            
                            // Optional tags section.
                            HStack {
                                Text("Optional Tags:")
                                    .font(.custom("HelveticaNeue", size: 20))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Button(action: { showingTagInfo.toggle() }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(AppTheme.primaryBlue)
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
                            
                            // Save Entry button using your custom ZenButtonStyle.
                            Button(action: {
                                viewModel.addEntry(text: text, tags: selectedTags)
                                text = ""
                                selectedTags = []
                            }) {
                                Text("Save Entry")
                                    .font(.custom("HelveticaNeue-Bold", size: 24))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.primaryBlue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
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
                .font(.custom("HelveticaNeue", size: 30))
                .padding(10)
                .background(isSelected ? AppTheme.primaryBlue.opacity(0.4) : Color(.systemGray6))
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
            ZStack {
                AppTheme.backgroundBlue.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Personalize your journal with custom tags! Swipe left to remove a tag, or tap the pencil to edit.")
                        .font(.custom("HelveticaNeue", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    
                    List {
                        ForEach(viewModel.customTags.indices, id: \.self) { index in
                            let tag = viewModel.customTags[index]
                            HStack {
                                Text(tag.emoji)
                                    .font(.custom("HelveticaNeue", size: 30))
                                Text(tag.description)
                                    .font(.custom("HelveticaNeue", size: 20))
                                Spacer()
                                Button(action: {
                                    editingTag = tag
                                    editingIndex = index
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(AppTheme.primaryBlue)
                                }
                            }
                            .listRowBackground(AppTheme.backgroundBlue)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { viewModel.removeTag(at: $0) }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            // Use the standard navigation title:
            .navigationTitle("Custom Tags")
            .navigationBarItems(
                leading: Button("Done") { dismiss() }
                    .font(.custom("HelveticaNeue", size: 20)),
                trailing: Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus")
                }
            )
            .onAppear {
                // Configure the navigation bar appearance to update title font and color.
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(AppTheme.backgroundBlue)
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor(AppTheme.textPrimary),
                    .font: UIFont(name: "HelveticaNeue", size: 40)!
                ]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
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

