//
//  ContentView.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = JournalViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    
    private var todayFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: Date())
}
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            TabView {
                JournalEntryView(viewModel: viewModel)
                    .tabItem {
                        Label(todayFormatted, systemImage: "square.and.pencil")
                    }

                JournalHistoryView(viewModel: viewModel)
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }

                ReflectionView(viewModel: viewModel)
                    .tabItem {
                        Label("Reflections", systemImage: "sparkles")
                    }
                
                NotificationSettingsView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell.fill")
                    }
            }
            .tint(AppTheme.primaryBlue)
            .background(AppTheme.backgroundBlue)
        }
    }
}

#Preview {
    ContentView()
        .onAppear {
            // Force onboarding to show in preview
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }
}


