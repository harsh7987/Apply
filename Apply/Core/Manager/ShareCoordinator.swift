//
//  ShareCoordinator.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

// Core/Manager/ShareCoordinator.swift
import SwiftUI

import SwiftUI
import SwiftData

struct EmailDraftData: Identifiable {
    let id = UUID()
    let subject: String
    let body: String
    let recipients: [String]
}

@Observable
class ShareCoordinator {
    static let shared = ShareCoordinator()
    
    // Config
    let APP_GROUP_ID = "group.com.harsh.verma.apply"
    
    // State
    var incomingUrl: String?
    var showNewJobAlert = false
    var isScraping = false
    var showPreviewSheet = false
    
    // NEW STATES for Default Flow
    var showTemplateSelector = false
    var showMailComposer = false
    var mailData: EmailDraftData?
    
    var showErrorAlert = false
    var errorMessage = ""
    
    // Data
    var currentScrapedJob: ScrapedJob?
    
    // 🧠 The "Remote Control" for our background worker
    var scrapeTask: Task<Void, Never>?
    
    // Helper to read settings (Since @AppStorage acts weird in Classes)
    var useDefaultTemplates: Bool {
        get { UserDefaults.standard.bool(forKey: "useDefaultTemplates") }
        set { UserDefaults.standard.set(newValue, forKey: "useDefaultTemplates") }
    }

    private init() {}

    func checkMailbox() {
        print("📬 Checking Mailbox...")
        guard let userDefaults = UserDefaults(suiteName: APP_GROUP_ID) else { return }
        
        if let content = userDefaults.string(forKey: "shared_content_data") {
            print("✅ MAILBOX: Found content: \(content)")
            self.incomingUrl = content
            self.showNewJobAlert = true
            
            userDefaults.removeObject(forKey: "shared_content_data")
            userDefaults.removeObject(forKey: "shared_content_is_url")
        }
    }
    
    // MARK: - The New Logic 🧠
    
    func handleApplyClick() {
        guard let url = incomingUrl else { return }
        
        self.showNewJobAlert = false
        self.isScraping = true
        
        // 1. Start the Scrape (Fire and Save the Receipt)
        // We wrap the old completion-handler function into an async one
        scrapeTask = Task {
            print("🚀 Starting Background Scrape for: \(url)")
            await self.performAsyncScrape(url: url)
        }
        
        // 2. Decide UI Path
        if useDefaultTemplates {
            print("🔀 Path A: Showing Template Selector Immediately")
            showTemplateSelector = true
        } else {
            print("🔀 Path B: Standard AI Flow")
            // Wait for the task we just started
            Task {
                _ = await scrapeTask?.value
                // Once finished, show preview
                await MainActor.run {
                    if self.currentScrapedJob != nil {
                        self.showPreviewSheet = true
                    }
                }
            }
        }
    }
    
    // 🌉 Bridge: Turns your old "Callback" scraper into "Async/Await"
    private func performAsyncScrape(url: String) async {
            print("🚀 ShareExtension: Starting Smart Scrape...")
        
        guard let checkURL = URL(string: url),
                  let scheme = checkURL.scheme,
                  ["http", "https"].contains(scheme.lowercased()) 
            else {
                print("❌ Error: Invalid URL or Scheme.")
                
                await MainActor.run {
                    self.isScraping = false
                    self.errorMessage = "This link looks broken or invalid. Please check it and try again."
                    self.showErrorAlert = true
                    self.showTemplateSelector = false
                }
                return
            }
            
            // 1. Spinner ON
            await MainActor.run { self.isScraping = true }
            
            // 2. Call the New Safe Wrapper (Timeout Logic Included)
            // This internally calls 'scrape', so the old logic still runs!
            let job = await JobScraperManager.shared.scrapeAsync(url: url)
            
            // 3. Handle Result
            await MainActor.run {
                self.isScraping = false // Spinner OFF
                
                if let job = job {
                    print("✅ ShareExtension: Job Found!")
                    self.currentScrapedJob = job
                } else {
                    print("❌ ShareExtension: Timeout or Failed")
                    self.showTemplateSelector = false
                    self.errorMessage = "We couldn't extract job details. Please try a valid LinkedIn or Indeed link."
                    self.showErrorAlert = true
                }
            }
        }
    
    // MARK: - Selection Handlers
    
    func handleTemplateSelection(template: UserTemplate) {
        print("👤 User selected template: \(template.title)")
        
        Task {
            // 1. The Wait: If scraper is running, we pause here (off main thread)
            if isScraping {
                print("⏳ Scraper still running... waiting.")
            }
            _ = await scrapeTask?.value
            print("✅ Scraper finished. Preparing mail.")
            
            // 2. The Handoff
            if let job = currentScrapedJob {
                let subject = template.subject
                let body = template.body
                // Fallback if scraping email failed
                let recipients = [job.hrEmail ?? ""]
                
                await MainActor.run {
                    self.showTemplateSelector = false
                    self.mailData = EmailDraftData(subject: subject, body: body, recipients: recipients)
                    self.showMailComposer = true
                }
            } else {
                print("❌ Error: Scrape failed, cannot send mail.")
                // Optional: Show an error alert here
            }
        }
    }
    
    func handleAISelection() {
        print("✨ User selected AI Magic")
        Task {
            // Wait for scrape to finish
            _ = await scrapeTask?.value
            
            await MainActor.run {
                // If the scrape FAILED, force close everything
                if self.currentScrapedJob == nil {
                    self.showTemplateSelector = false
                    // The error alert from performAsyncScrape will handle the UI
                    return
                }
                
                // Success path
                self.showTemplateSelector = false
                self.showPreviewSheet = true
            }
        }
    }
}
