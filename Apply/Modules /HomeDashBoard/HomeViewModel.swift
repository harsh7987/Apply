//
//  HomeViewModel.swift
//  Apply
//
//  Created by Pranjal Verma on 23/01/26.
//
import SwiftUI
import SwiftData
internal import MessageUI

@Observable
class HomeViewModel {
    // MARK: - Properties
    
    var scrapeTask: Task<ScrapedJob?, Never>?
    
    // 2. Data Holders
    var scrapedJob: ScrapedJob?
    var mailData: EmailDraftData?
    
    // 3. UI Triggers
    var isScrapingTrue = false
    var showTemplateSelector = false
    var showMailComposer = false
    var showPreviewSheet = false
    
    var showErrorAlert = false
    var errorMessage = ""
    
    // 4. Settings (Bridge to UserDefaults)
    var useDefaultTemplates: Bool {
        get { UserDefaults.standard.bool(forKey: "useDefaultTemplates") }
        set { UserDefaults.standard.set(newValue, forKey: "useDefaultTemplates") }
    }
    
    var mailResult: ComposeResult? = nil
    
    // MARK: - Actions
    
    @MainActor
    func scrapeLink(url: String) {
        print("🚀 Starting Smart Scrape for: \(url)")
        guard let checkURL = URL(string: url),
              let scheme = checkURL.scheme,
              ["http", "https"].contains(scheme.lowercased())
        else {
            print("❌ Error: Invalid URL or Scheme.")
            
            self.isScrapingTrue = false
            self.errorMessage = "This link looks broken or invalid. Please check it and try again."
            self.showErrorAlert = true
            self.showTemplateSelector = false
            
            return
        }
        
        self.isScrapingTrue = true
        
        // 1. Fire the Task & Save it
        scrapeTask = Task {
            // Call the async wrapper we made in Manager
            let job = await JobScraperManager.shared.scrapeAsync(url: url)
            
            self.isScrapingTrue = false
            if let job = job {
                self.scrapedJob = job
            } else {
                print("❌ Scrape Failed")
                self.showTemplateSelector = false
                self.errorMessage = "We couldn't find a job details in that link. Please try a valid LinkedIn or Indeed URL."
                self.showErrorAlert = true
            }
            return job
        }
        
        // 2. Decide the Path
        if useDefaultTemplates {
            print("⚡️ Use Default: Showing Overlay Immediately")
            self.showTemplateSelector = true
        } else {
            // Standard Path: Wait for task
            Task {
                _ = await scrapeTask?.value
                if self.scrapedJob != nil {
                    self.showPreviewSheet = true
                }
            }
        }
    }
    
    @MainActor
    func handleTemplateSelection(template: UserTemplate) {
        print("👤 User selected template: \(template.title)")
        
        Task {
            // 1. WAIT! If the scraper is still running, this line pauses execution.
            if isScrapingTrue { print("⏳ Waiting for scraper to finish...") }
            
            let _ = await scrapeTask?.value
            
            // 2. Now we definitely have the job (or nil)
            if let job = self.scrapedJob {
                print("✅ Data ready. Launching Mail Composer.")
                
                let subject = template.subject
                let body = template.body
                let recipients = [job.hrEmail ?? ""]
                
                await MainActor.run {
                    self.showTemplateSelector = false // Close Overlay
                    // Trigger your Mail Composer logic here
                    self.mailData = EmailDraftData(subject: subject, body: body, recipients: recipients)
                    self.showMailComposer = true
                }
            } else {
                print("❌ Scrape failed. Cannot send mail.")
            }
        }
    }
    
    @MainActor
        func handleAISelection() {
            print("✨ User chose AI Magic: Switching flow...")
            
            // 1. Close the Overlay immediately
            self.showTemplateSelector = false
            
            Task {
                // 2. Wait for the Scraper (if it's still running)
                if isScrapingTrue { print("⏳ AI waiting for scraper...") }
                
                let _ = await scrapeTask?.value
                
                // 3. Check if we have data
                if self.scrapedJob != nil {
                    // 4. Open the Standard AI Sheet
                    self.showPreviewSheet = true
                } else {
                    // If scraping failed, the error alert from scrapeLink() will usually handle it,
                    // but just in case:
                    print("❌ Cannot open AI Preview: No job data.")
                }
            }
        }
    
    @MainActor
    func saveApplication(context: ModelContext) {
        guard let job = self.scrapedJob else { return }
        guard let data = self.mailData else { return }
        
        print("💾 Saving Application: \(job.title)")
        
        let newApp = JobApplication(
            companyName: "Unknown Company",
            jobTitle: job.title,
            jobDescription: job.cleanDescription,
            hrEmail: job.hrEmail,
            generatedSubject: data.subject, // Fallback subject
            generatedBody: data.body, // Placeholder body
            url: job.url,
            status: "Sent",
            applicationMethod: .manualEmail // 👈 CRITICAL: Mark as Manual
        )
        
        // 3. Insert into Database
        context.insert(newApp)
        try? context.save()
        
        // 4. Trigger Follow-up Timer ⏰
        NotificationManager.shared.scheduleFollowUp(for: newApp)
        
        // 5. Cleanup
        self.scrapedJob = nil
        self.mailData = nil
        print("✅ Application Saved & Timer Started!")
    }
    
}
