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
    let APP_GROUP_ID = "group.com.harsh007.ApplyNew"
    
    // State
    var incomingUrl: String?
    var showNewJobAlert = false
    var isScraping = false
    var showPreviewSheet = false
    
    // NEW STATES for Default Flow
    var showTemplateSelector = false
    var showMailComposer = false
    var mailData: EmailDraftData?
    
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
        await MainActor.run { self.isScraping = true }
        
        return await withCheckedContinuation { continuation in
            // Calling your existing manager
            JobScraperManager.shared.scrape(url: url) { [weak self] job in
                self?.currentScrapedJob = job
                
                Task { @MainActor in
                    self?.isScraping = false
                }
                // Resume the 'await' line - Scrape is DONE
                continuation.resume(returning: ())
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
                self.showTemplateSelector = false
                if self.currentScrapedJob != nil {
                    self.showPreviewSheet = true
                }
            }
        }
    }
}
