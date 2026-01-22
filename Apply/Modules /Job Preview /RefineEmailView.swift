//
//  RefineEmailView.swift
//  Apply
//
//  Created by Pranjal Verma on 13/01/26.
//

import SwiftUI
internal import MessageUI
import SwiftData

struct RefineEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // We fetch users here to get the profile for the AI
    @Query private var users: [UserProfile]
    
    // --- INPUTS (Passed from Previous Screen) ---
    let existingDraft: JobApplication?
    let job: ScrapedJob?
    
    private var effectiveJob: ScrapedJob? {
        if let job = job { return job }
        
        return existingDraft?.asScrapedJob
    }
    
    // --- CONFIGURATION STATES (Editable) ---
    @State private var selectedTone: ToneOption
    @State private var userPrompt: String
    
    // --- OUTPUT STATES (The AI writes here) ---
    @State private var generatedSubject: String = ""
    @State private var generatedBody: String = ""
    @State private var companyName: String = ""
    
    // --- LOGIC STATES ---
    @State private var isLoading = false
    @State private var triggerGeneration = false // The Toggle Switch
    @State private var showMailComposer = false
    @State private var showDraftAlert = false
    @State private var mailResult: ComposeResult?
    
    // ----Follow Up Model----
    var isFollowUpMode: Bool
    
    @State private var showExitAlert = false
    
    init(
        job: ScrapedJob? = nil,
        existingDraft: JobApplication? = nil,
        tone: ToneOption = .professional,
        prompt: String = "",
        isFollowUpMode: Bool = false
    ) {
        self.job = job
        self.existingDraft = existingDraft
        
        _generatedSubject = State(initialValue: existingDraft?.generatedSubject ?? "")
        _generatedBody = State(initialValue: existingDraft?.generatedBody ?? "")
        _selectedTone = State(initialValue: tone)
        _userPrompt = State(initialValue: prompt)
        
        // If we have a draft, we aren't "loading" the first AI call
        _isLoading = State(initialValue: existingDraft == nil)
        self.isFollowUpMode = isFollowUpMode
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // =========================================
            // MARK: 1. Controls (Tone & Prompt)
            // =========================================
            VStack(alignment: .leading, spacing: 10) {
                // Tone Picker
                Picker("Tone", selection: $selectedTone) {
                    ForEach(ToneOption.allCases) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .pickerStyle(.segmented)
                
                // Prompt Field
                TextField("Add instructions (e.g. 'Make it shorter')", text: $userPrompt)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // =========================================
            // MARK: 2. The Editor
            // =========================================
            if isLoading && generatedBody.isEmpty {
                // Initial Load State (Skeleton)
                VStack(spacing: 20) {
                    Spacer()
                    ProgressView("AI is writing your email...")
                        .controlSize(.large)
                    Text("Using tone: \(selectedTone.rawValue)")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                Form {
                    Section("Subject Line") {
                        TextField("Subject", text: $generatedSubject)
                            .font(.headline)
                    }
                    
                    Section("Email Body") {
                        // We use ZStack to show spinner during re-generation
                        ZStack(alignment: .center) {
                            TextEditor(text: $generatedBody)
                                .frame(minHeight: 300)
                                .font(.body)
                                .opacity(isLoading ? 0.5 : 1.0) // Dim text when regenerating
                            
                            if isLoading {
                                ProgressView()
                                    .controlSize(.large)
                            }
                        }
                    }
                    
                    // =========================================
                    // MARK: 3. Regenerate Button
                    // =========================================
                    Section {
                        Button {
                            FeedbackManager.shared.impact(.heavy)
                            triggerGeneration.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                if isLoading {
                                    Text("Regenerating...")
                                } else {
                                    Label("Regenerate", systemImage: "arrow.triangle.2.circlepath")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                        }
                        .disabled(isLoading) // Prevent Button Spam
                        .listRowBackground(Color.blue.opacity(0.1))
                    }
                }
            }
        }
        .navigationTitle("Refine Email")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    
                    if existingDraft != nil {
                        dismiss()
                    } else {
                        showDraftAlert = true
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Send") { showMailComposer = true }
                    .fontWeight(.bold)
                    .disabled(isLoading || generatedBody.isEmpty)
            }
        }
        .interceptDismiss(showAlert: $showExitAlert)
        
        // 3. Add the Alert
//        .alert("Close Preview?", isPresented: $showExitAlert) {
//            Button("Cancel", role: .cancel) { }
//            Button("Close", role: .destructive) {
//                dismiss()
//            }
//        } message: {
//            Text("You will lose this generated cover letter.")
//        }
        
        // =========================================
        // MARK: ALERTS & SHEETS
        // =========================================
        .confirmationDialog("Cancel Application?", isPresented: $showDraftAlert) {
            Button("Save as Draft") {
                saveApplication(status: "Draft")
                dismiss()
            }
            Button("Discard Changes", role: .destructive) {
                FeedbackManager.shared.trigger(.warning)
                dismiss()
            }
            Button("Keep Editing", role: .cancel) { }
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(
                result: $mailResult,
                subject: generatedSubject,
                genratedBody: generatedBody,
                recipients: [effectiveJob?.hrEmail ?? ""],
                attachmentURL: CVManager.shared.cvURL,
                coverLetterURL: CoverLetterManager.shared.coverLetterURL
            )
        }
        .onChange(of: mailResult) { _, newValue in
            handleMailResult(newValue)
        }
        
        // =========================================
        // MARK: LOGIC TRIGGERS
        // =========================================
        
        // 1. Initial Load (Auto-Start)
        .onAppear {
            FeedbackManager.shared.playTokenSpendSound()
            if existingDraft?.status == "Sent" {
                callAI()
            }else if generatedBody.isEmpty {
                callAI()
            }
        }
        
        // 2. Re-Generation (Button Click)
        .onChange(of: triggerGeneration) { _, _ in
            FeedbackManager.shared.playTokenSpendSound()
            callAI()
        }
    }
    
    // =========================================
    // MARK: FUNCTIONS
    // =========================================
    
    func callAI() {
        guard let jobToUse = effectiveJob else {
            print("❌ Error: No job context found!")
            return
        }
        isLoading = true
        
        let basePrompt = (existingDraft?.status == "Sent")
        ? "This is a follow-up email. Be polite and ask if they had a chance to review my previous application."
        : userPrompt
        
        // 1. Get User Profile (Default if empty)
        let currentUser = users.first ?? UserProfile(name: "Applicant", email: "", phoneNumber: "", experience: "", skills: "")
        
        // 2. Build Request
        let request = GenerationRequest(
            user: currentUser,
            job: jobToUse,
            tone: selectedTone,
            userPrompt: basePrompt
        )
        
        // 3. Fire API
        Task {
            do {
                let result = try await AIService.shared.generateCoverLetter(request: request)
                
                await MainActor.run {
                    self.generatedSubject = result.subject
                    self.generatedBody = result.body
                    self.companyName = result.company ?? "Unknown Company"
                    self.isLoading = false
                }
            } catch {
                print("❌ AI Error: \(error)")
                await MainActor.run { isLoading = false }
            }
        }
    }
    
    func handleMailResult(_ result: ComposeResult?) {
        guard let result = result else { return }
        
        switch result {
        case .success(let status):
            if status == .sent {
                //    Success Sound & Haptic
                FeedbackManager.shared.playSendSound()
                FeedbackManager.shared.trigger(.success)
                saveApplication(status: "Sent")
            }
        case .failure(let error):
            FeedbackManager.shared.trigger(.error)
            print("❌ Mail Error: \(error)")
        }
        
        showMailComposer = false
        
        // Small delay to let the sheet dismiss smoothly before popping view
        if case .success(.sent) = result {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
    
    func saveApplication(status: String) {
        // 🆕 PATH A: FOLLOW-UP MODE (The Re-Birth Logic)
        if isFollowUpMode, let app = existingDraft {
            print("🚀 Processing Follow-Up...")
            if status == "Sent" {
                app.generatedSubject = generatedSubject
                app.generatedBody = generatedBody
                
                app.markFollowUpSent(context: modelContext)
            }
            return
        }
        
        let applicationToProcess: JobApplication
        
        if let draft = existingDraft {
            // ✅ Case A: Update existing
            draft.generatedSubject = generatedSubject
            draft.generatedBody = generatedBody
            draft.status = status
            draft.appliedDate = Date()
            applicationToProcess = draft // Point our local variable to the draft
            
        } else if let job = job {
            // ✅ Case B: Create new
            let newApp = JobApplication(
                companyName: companyName,
                jobTitle: job.title,
                jobDescription: job.cleanDescription,
                hrEmail: job.hrEmail,
                generatedSubject: generatedSubject,
                generatedBody: generatedBody,
                url: job.url,
                status: status
            )
            modelContext.insert(newApp)
            applicationToProcess = newApp // Point our local variable to the new app
        } else {
            return // Safety check: nothing to save
        }
        
        // 2. Perform the save
        do {
            try modelContext.save()
            print("💾 Saved Application as \(status)")
            
            // 3. Use our local reference for the notification
            if status == "Sent" {
                NotificationManager.shared.scheduleFollowUp(for: applicationToProcess)
            }
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
}

#Preview {
    RefineEmailView(job: ScrapedJob(
        title: "#Hiring #MobileDeveloper #iOSDeveloper #AndroidDeveloper #ReactNative #Flutter #SDE4 #Nickelfox #TechJobs #NoidaJobs",
        cleanDescription: """
            🚀 We’re Hiring: SDE 4 – Mobile Application Developer
            📍 Location: Noida (Work From Office)
            🕒 Experience: 4–6 Years | Full-time

            Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4) with deep expertise in native iOS development and solid exposure to Android and cross-platform frameworks (React Native / Flutter).

            This role is for engineers who think beyond features and care about architecture, performance, scalability, and clean code.

            🔧 Key Responsibilities:
            Own end-to-end development of complex mobile features (primarily iOS)
            Design and evolve mobile architecture (MVVM, Clean Architecture, modularization)
            Review and contribute to Android codebases
            Guide teams on React Native / Flutter feasibility and trade-offs
            Ensure performance, security, and production readiness
            Mentor junior engineers and lead code reviews

            ✅ Requirements:
            4–6 years of mobile app development experience
            Strong expertise in Swift, UIKit, SwiftUI
            Hands-on experience with Android (Kotlin preferred)
            Working knowledge of React Native or Flutter
            Experience with production-scale apps
            Strong ownership and problem-solving mindset

            ✨ Why Join Nickelfox?
            Work on real-world, scalable mobile products
            High ownership and real technical influence
            Opportunity to grow into staff-level or architectural roles

            📩 Interested?
            Share your resume at careers@niceklfox.com
             or tag someone who’d be a great fit!
            Shraddha Shrivastava Shivani Sharma Sweeti Kumari
            """,
        rawDescription: """
            🚀 We’re Hiring: SDE 4 – Mobile Application Developer
            📍 Location: Noida (Work From Office)
            🕒 Experience: 4–6 Years | Full-time

            Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4) with deep expertise in native iOS development and solid exposure to Android and cross-platform frameworks (React Native / Flutter).

            This role is for engineers who think beyond features and care about architecture, performance, scalability, and clean code.

            🔧 Key Responsibilities:
            Own end-to-end development of complex mobile features (primarily iOS)
            Design and evolve mobile architecture (MVVM, Clean Architecture, modularization)
            Review and contribute to Android codebases
            Guide teams on React Native / Flutter feasibility and trade-offs
            Ensure performance, security, and production readiness
            Mentor junior engineers and lead code reviews

            ✅ Requirements:
            4–6 years of mobile app development experience
            Strong expertise in Swift, UIKit, SwiftUI
            Hands-on experience with Android (Kotlin preferred)
            Working knowledge of React Native or Flutter
            Experience with production-scale apps
            Strong ownership and problem-solving mindset

            ✨ Why Join Nickelfox?
            Work on real-world, scalable mobile products
            High ownership and real technical influence
            Opportunity to grow into staff-level or architectural roles

            📩 Interested?
            Share your resume at careers@niceklfox.com
             or tag someone who’d be a great fit!
            Shraddha Shrivastava Shivani Sharma Sweeti Kumari
            """,
        hrEmail: "careers@niceklfox.com",
        url: "https://www.linkedin.com/posts/seema-diwakr_hiring-mobiledeveloper-iosdeveloper-activity-7415252598548533248-wJgr?utm_medium=ios_app&rcm=ACoAAEGjvOcBLTgyu3-MZbOsl3rWuk8KALWdhqA&utm_source=social_share_send&utm_campaign=share_via"),
                    tone: .professional,
                    prompt: "Hey")
}
