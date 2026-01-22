//
//  HomeView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    // 1. Observe the global navigation state
    @StateObject private var navManager = AppNavigationManager.shared
    
    @Query(filter: #Predicate<JobApplication> { app in
        app.status == "Draft"
    }, sort: \.appliedDate, order: .reverse)
    private var drafts: [JobApplication]
    
    var body: some View {
        // 2. Bind the TabView to the manager's selectedTab
        TabView(selection: $navManager.selectedTab) {
            
            // TAB 0: HOME
            ZStack {
                BackgroundView()
                VStack(alignment: .center) {
                    HomeTextView()
                    StatsViews()
                    RoundedButtonView()
                    Spacer()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0) // 👈 Important for binding
            
            // TAB 1: DRAFTS
            NavigationStack {
                DraftsView()
            }
                .tabItem {
                    Label("Drafts", systemImage: "document")
                }
                .badge(drafts.count > 0 ? drafts.count : 0)
                .tag(1)
            
            // TAB 2: HISTORY (RECENT ACTIVITY)
            NavigationStack {
                RecentActivityView()
            }
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(2) // 👈 This is where notifications point to
            
            // TAB 3: SETTINGS
            NavigationStack {
                SettingsView()
            }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted { print("✅ Permission Granted!") }
        }
    }
}

#Preview {
    HomeView()
}
  
