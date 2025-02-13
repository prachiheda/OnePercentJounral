//
//  ContentView.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = JournalViewModel()  // Shared ViewModel

    var body: some View {
        TabView {
            JournalEntryView(viewModel: viewModel)
                .tabItem {
                    Label("New Entry", systemImage: "square.and.pencil")
                }

            JournalHistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            ReflectionView(viewModel: viewModel)
                .tabItem {
                    Label("Reflections", systemImage: "sparkles")
                }
        }
    }
}

#Preview {
    ContentView()
}


