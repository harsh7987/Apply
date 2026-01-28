//
//  HomeView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData
internal import MessageUI

struct HomeView: View {
    
    // 1. Observe the global navigation state
    @StateObject private var navManager = AppNavigationManager.shared
    @Environment(\.modelContext) var modelContext
    @State private var viewModel = HomeViewModel()
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
                    RoundedButtonView(viewModel: viewModel)
                    Spacer()
                }
            }
            .overlay {
                if viewModel.showTemplateSelector {
                    // Background Dimming
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { viewModel.showTemplateSelector = false }
                    
                    // The Popup
                    TemplateSelectorView(
                        onSelectAI: {
                            viewModel.handleAISelection()
                        },
                        onSelectTemplate: { template in
                            // Call the function we wrote earlier
                            viewModel.handleTemplateSelection(template: template)
                        },
                        onCancel: { viewModel.showTemplateSelector = false }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .sheet(isPresented: $viewModel.showMailComposer) {
                if let data = viewModel.mailData {
                    MailComposerView(
                        result: $viewModel.mailResult, // 👈 PASS THE BINDING
                        subject: data.subject,
                        genratedBody: data.body,
                        recipients: data.recipients,
                        attachmentURL: CVManager.shared.cvURL,
                        coverLetterURL: CoverLetterManager.shared.coverLetterURL
                    )
                }
            }
            
            .onChange(of: viewModel.mailResult != nil) { _, hasResult in
                guard hasResult else { return }
                
                if let result = viewModel.mailResult {
                    // Switch on our custom enum
                    switch result {
                    case .success(let status):
                        if status == .sent {
                            print("✅ Home: Mail Sent!")
                            viewModel.saveApplication(context: modelContext)
                            FeedbackManager.shared.trigger(.success)
                        }
                    case .failure(let errorString):
                        print("❌ Mail Error: \(errorString)")
                    }
                    
                    // Reset
                    viewModel.mailResult = nil
                }
            }
            // 3. The Job Preview Sheet (For the "False" path)
            .sheet(isPresented: $viewModel.showPreviewSheet) {
                if let job = viewModel.scrapedJob {
                    JobPreviewView(job: job)
                }
            }
            .alert("Link Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
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
  
