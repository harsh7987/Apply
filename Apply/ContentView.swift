//
//  ContentView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI
import SwiftData
internal import MessageUI

struct ContentView: View {
    // 1. Get the stable singleton (No @State needed here for reference)
    @Environment(\.modelContext) var modelContext // 1. Need Context to save
    @State private var manualMailResult: ComposeResult?
    var shareCoordinator = ShareCoordinator.shared
    
    // 2. Draft Badge Logic
    @Query(filter: #Predicate<JobApplication> { $0.status == "Draft" })
    var activeDrafts: [JobApplication]
    
    var body: some View {
        // 3. Create the Bindable proxy for bindings ($)
        @Bindable var coordinator = shareCoordinator
        
        ZStack { // 👈 Wrap HomeView in a ZStack so we can float the spinner on top
            HomeView()
            // 👇 ADD THIS LOADING SPINNER
            if coordinator.isScraping {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView("Analyzing Link...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        // ⬇️ GLOBAL OVERLAYS (Attached to the Parent) ⬇️
        
        // A. New Job Alert
            .alert("New Job Detected!", isPresented: $coordinator.showNewJobAlert) {
                Button("Apply Now") { shareCoordinator.handleApplyClick() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Received link: \(shareCoordinator.incomingUrl ?? "Unknown")")
            }
            .alert("Scraping Error", isPresented: $coordinator.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(shareCoordinator.errorMessage)
            }
        
        // B. Template Selector (Force Quit Style)
            .overlay {
                if coordinator.showTemplateSelector {
                    TemplateSelectorView(
                        onSelectAI: { shareCoordinator.handleAISelection() },
                        onSelectTemplate: { shareCoordinator.handleTemplateSelection(template: $0) },
                        onCancel: {
                            coordinator.showTemplateSelector = false
                            coordinator.isScraping = false
                            coordinator.scrapeTask?.cancel()
                        }
                    )
                }
            }
        
        // C. Job Preview Sheet
            .sheet(isPresented: $coordinator.showPreviewSheet) {
                if let job = shareCoordinator.currentScrapedJob {
                    JobPreviewView(job: job)
                }
            }
        
        // D. Mail Composer Sheet
            .sheet(isPresented: $coordinator.showMailComposer) {
                if let data = shareCoordinator.mailData {
                    MailComposerView(
                        result: $manualMailResult,
                        subject: data.subject,
                        genratedBody: data.body,
                        recipients: data.recipients,
                        attachmentURL: CVManager.shared.cvURL,
                        coverLetterURL: CoverLetterManager.shared.coverLetterURL
                    )
                }
            }
        
        // D.2. LISTEN FOR SUCCESS (The "Save" Trigger)
            .onChange(of: manualMailResult) { _, newValue in
                guard let result = newValue else { return }
                
                if case .success(let status) = result {
                    if status == .sent {
                        print("✅ Manual Mail Sent!")
                        //    Success Sound & Haptic
                        FeedbackManager.shared.playSendSound()
                        FeedbackManager.shared.trigger(.success)
                        saveManualApplication()
                    }
                }
                // Reset
                manualMailResult = nil
            }
        
        
        
        // E. Deep Links
            .onOpenURL { url in
                shareCoordinator.checkMailbox()
            }
    }
    
    
    // 5. THE SAVE FUNCTION
    func saveManualApplication() {
        guard let job = shareCoordinator.currentScrapedJob else { return }
        guard let data = shareCoordinator.mailData else { return }
        
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
        
        modelContext.insert(newApp)
        try? modelContext.save()
        
        // Start the Follow-up Timer!
        NotificationManager.shared.scheduleFollowUp(for: newApp)
        
        // Clean up
        shareCoordinator.currentScrapedJob = nil
    }
    
}
