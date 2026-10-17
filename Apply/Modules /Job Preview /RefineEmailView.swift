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
    // 1. ENVIRONMENT & DATA
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    // 2. QUERY FOR AI PROFILE
    @Query private var users: [UserProfile]
    
    // 3. INPUTS
    let existingDraft: JobApplication?
    let job: ScrapedJob?
    var isFollowUpMode: Bool
    
    private var effectiveJob: ScrapedJob? {
        if let job = job { return job }
        return existingDraft?.asScrapedJob
    }
    
    // 4. CONFIGURATION STATES (Inputs)
    @State private var selectedTone: ToneOption
    @State private var userPrompt: String
    
    // 5. OUTPUT STATES (The AI writes here)
    @State private var generatedSubject: String = ""
    @State private var generatedBody: String = ""
    @State private var companyName: String = ""
    
    // 6. LOGIC STATES
    @State private var isLoading = false
    @State private var showMailComposer = false
    @State private var showDraftAlert = false
    @State private var mailResult: ComposeResult?
    @State private var isRefinementExpanded: Bool = false // UI Toggle
    @State private var showSubscription = false
    @State private var showNoMailAlert = false
    
    // Prevent accidental dismiss
    @State private var showExitAlert = false
    
    // 7. INIT
    init(
        job: ScrapedJob? = nil,
        existingDraft: JobApplication? = nil,
        tone: ToneOption = .professional,
        prompt: String = "",
        isFollowUpMode: Bool = false
    ) {
        self.job = job
        self.existingDraft = existingDraft
        self.isFollowUpMode = isFollowUpMode
        
        _generatedSubject = State(initialValue: existingDraft?.generatedSubject ?? "")
        _generatedBody = State(initialValue: existingDraft?.generatedBody ?? "")
        _selectedTone = State(initialValue: tone)
        _userPrompt = State(initialValue: prompt)
        
        // If no draft exists, we load immediately
        _isLoading = State(initialValue: existingDraft == nil)
    }
    
    var body: some View {
        ZStack {
            // A. BACKGROUND
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color(red: 0.97, green: 0.97, blue: 0.98).ignoresSafeArea()
            }
            
            // B. MAIN UI
            VStack(spacing: 0) {
                
                // 1. HEADER
//                HStack {
//                    Text("Draft Preview")
//                        .font(.system(size: 20, weight: .bold, design: .rounded))
//                        .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    Spacer()
//                    Button("Close") { showDraftAlert = true }
//                        .foregroundStyle(.secondary)
//                }
//                .padding(24)
                
                // 2. SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 20) {
                        // THE DOCUMENT CARD (Subject & Body)
                        DocumentCard(
                            emailSubject: $generatedSubject,
                            emailBody: $generatedBody,
                            colorScheme: colorScheme
                        )
                        
                        // THE REFINEMENT SECTION (Edit & Regenerate)
                        RefinementSection(
                            isExpanded: $isRefinementExpanded,
                            selectedTone: $selectedTone,
                            refinementInstructions: $userPrompt, // Binds to userPrompt
                            colorScheme: colorScheme,
                            onRegenerate: {
                                // Trigger Regeneration
                                callAI()
                            }
                        )
                    }
                    .padding(20)
                }
                
                // 3. BOTTOM BAR (Action)
                BottomBar(
                    colorScheme: colorScheme,
                    isDisabled: isLoading || generatedBody.isEmpty,
                    action: {
                        if MFMailComposeViewController.canSendMail() {
                            showMailComposer = true
                        } else {
                            showNoMailAlert = true
                        }
                    }
                )
                .padding(24)
                .background(Material.ultraThin)
            }
            
            // C. HOLOGRAPHIC LOADER (The God Mode Overlay)
            if isLoading {
                HolographicProcessingView()
                    .zIndex(2)
                    .transition(.opacity)
            }
            
            if showSubscription {
                CrystalSubscriptionView(
                    isPresented: $showSubscription,
                    manager: CreditManager.shared // Pass the Singleton!
                )
                .zIndex(3) // Make sure it sits on top of everything
            }
            
        }
        .navigationTitle("Refine Email")
        .toolbar(.hidden, for: .tabBar)
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
                .disabled(isLoading)
            }
        }
        .interceptDismiss(showAlert: $showExitAlert)

        // D. ALERTS & SHEETS
        .alert("Save as Draft?", isPresented: $showDraftAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Save Draft", role: .cancel) {
                saveApplication(status: "Draft")
                dismiss()
            }
        } message: {
            Text("Would you like to save this email to your drafts before closing?")
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
        // E. AUTO-START LOGIC
        .onAppear {
            if existingDraft?.status == "Sent" {
                callAI()
            }else if generatedBody.isEmpty {
                callAI()
            }
        }
        // F. No Mail Composer Alert
        .alert("Mail Not Configured", isPresented: $showNoMailAlert) {
            Button("Copy Email Body") {
                UIPasteboard.general.string = generatedBody
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please set up the Apple Mail app to send emails, or copy the draft to your clipboard.")
        }
    }
    
    // =========================================
    // MARK: - LOGIC FUNCTIONS (The Brain)
    // =========================================
    
    func callAI() {
        guard let jobToUse = effectiveJob else { return }
        
        // 🛑 1. THE MIDNIGHT CHECK (Fixes the 12:01 AM Loophole)
        // If they left the app open and the day changed, this resets it to 10 immediately before checking.
        CreditManager.shared.checkAndResetDailyTokens()
        
        // 🛑 2. THE TOLLBOOTH BLOCKER
        // If they have 0 tokens, show the paywall and STOP the function.
        guard CreditManager.shared.activeWallet?.tokenBalance ?? 0 > 0 else {
            withAnimation(.spring()) {
                showSubscription = true
            }
            return
        }
        
        withAnimation { isLoading = true }
        
        // Follow-Up Logic
        let basePrompt = (existingDraft?.status == "Sent")
        ? "This is a follow-up email. Be polite and ask if they had a chance to review my previous application. " + userPrompt
        : userPrompt
        
        let currentUser = users.first ?? UserProfile(name: "Applicant", email: "", phoneNumber: "", experience: "", skills: "")
        
        let request = GenerationRequest(
            user: currentUser,
            job: jobToUse,
            tone: selectedTone,
            userPrompt: basePrompt
        )
        
        Task {
            do {
                let result = try await AIService.shared.generateCoverLetter(request: request)
                
                // 🛑 3. THE DEDUCTION (The AI successfully worked!)
                // We only charge them a token because we know we got a result.
                CreditManager.shared.deductToken()
                
                await MainActor.run {
                    self.generatedSubject = result.subject
                    self.generatedBody = result.body
                    self.companyName = result.company ?? "Unknown Company"
                    withAnimation { self.isLoading = false }
                    FeedbackManager.shared.trigger(.success)
                }
            } catch {
                print("❌ AI Error: \(error)")
                await MainActor.run {
                    withAnimation { self.isLoading = false }
                    // Notice we DO NOT deduct a token here because it failed!
                    FeedbackManager.shared.trigger(.error)
                }
            }
        }
    }
    
    func handleMailResult(_ result: ComposeResult?) {
        guard let result = result else { return }
        
        switch result {
        case .success(let status):
            if status == .sent {
                FeedbackManager.shared.playSendSound()
                FeedbackManager.shared.trigger(.success)
                saveApplication(status: "Sent")
            }
        case .failure(let error):
            FeedbackManager.shared.trigger(.error)
            print("❌ Mail Error: \(error)")
        }
        
        showMailComposer = false
        
        if case .success(.sent) = result {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
    
    func saveApplication(status: String) {
        // FOLLOW-UP MODE
        if isFollowUpMode, let app = existingDraft {
            if status == "Sent" {
                app.generatedSubject = generatedSubject
                app.generatedBody = generatedBody
                app.markFollowUpSent(context: modelContext)
            }
            return
        }
        
        // STANDARD SAVE LOGIC
        let applicationToProcess: JobApplication
        
        if let draft = existingDraft {
            draft.generatedSubject = generatedSubject
            draft.generatedBody = generatedBody
            draft.status = status
            draft.appliedDate = Date()
            applicationToProcess = draft
        } else if let job = job {
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
            applicationToProcess = newApp
        } else {
            return
        }
        
        do {
            try modelContext.save()
            if status == "Sent" {
                NotificationManager.shared.scheduleFollowUp(for: applicationToProcess)
            }
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
}

// =========================================
// MARK: - UI COMPONENTS (The Body)
// =========================================

// 1. DOCUMENT CARD
private struct DocumentCard: View {
    @Binding var emailSubject: String
    @Binding var emailBody: String
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Subject
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SUBJECT")
                        .font(.caption).fontWeight(.bold).tracking(1)
                        .foregroundStyle(.gray)
                    Spacer()
                    Button(action: { UIPasteboard.general.string = emailSubject }) {
                        Image(systemName: "doc.on.doc").font(.caption).foregroundStyle(.blue)
                    }
                }
                TextField("Subject", text: $emailSubject)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            
            Divider().overlay(Color.gray.opacity(0.2))
            
            // Body
            ZStack(alignment: .topTrailing) {
                TextEditor(text: $emailBody)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.85))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 300)
                    .padding(16)
                
                Button(action: {
                    UIPasteboard.general.string = emailBody
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }) {
                    Image(systemName: "doc.on.doc").font(.caption).foregroundStyle(.blue)
                        .padding(16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// 2. REFINEMENT SECTION
private struct RefinementSection: View {
    @Binding var isExpanded: Bool
    @Binding var selectedTone: ToneOption
    @Binding var refinementInstructions: String
    var colorScheme: ColorScheme
    var onRegenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .symbolEffect(.bounce, value: isExpanded)
                    Text("Refine & Regenerate")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(Material.ultraThin)
                .foregroundStyle(.primary)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Tone
                    Text("ADJUST TONE").font(.caption.bold()).foregroundStyle(.gray).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ToneOption.allCases) { tone in
                                ToneChip(tone: tone, isSelected: selectedTone == tone) {
                                    selectedTone = tone
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Instructions
                    Text("CUSTOM INSTRUCTIONS").font(.caption.bold()).foregroundStyle(.gray).padding(.horizontal)
                    TextField("e.g. 'Make it more persuasive'...", text: $refinementInstructions, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.05)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        .padding(.horizontal)
                    
                    // Update Button
                    Button(action: onRegenerate) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Update Draft")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// 3. BOTTOM BAR
private struct BottomBar: View {
    var colorScheme: ColorScheme
    var isDisabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Open Mail Composer")
                    .font(.system(size: 16, weight: .bold))
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color(hex: "FFA500").opacity(0.4), radius: 10, x: 0, y: 5)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// Helper: Tone Chip (Same as before)
struct ToneChip: View {
    let tone: ToneOption
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(tone.rawValue)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundStyle(isSelected ? .white : (colorScheme == .dark ? .white : .black))
                .clipShape(Capsule())
        }
    }
}

//#Preview {
//    RefineEmailView(job: ScrapedJob(
//        title: "#Hiring #MobileDeveloper #iOSDeveloper #AndroidDeveloper #ReactNative #Flutter #SDE4 #Nickelfox #TechJobs #NoidaJobs",
//        cleanDescription: """
//            🚀 We’re Hiring: SDE 4 – Mobile Application Developer
//            📍 Location: Noida (Work From Office)
//            🕒 Experience: 4–6 Years | Full-time
//
//            Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4) with deep expertise in native iOS development and solid exposure to Android and cross-platform frameworks (React Native / Flutter).
//
//            This role is for engineers who think beyond features and care about architecture, performance, scalability, and clean code.
//
//            🔧 Key Responsibilities:
//            Own end-to-end development of complex mobile features (primarily iOS)
//            Design and evolve mobile architecture (MVVM, Clean Architecture, modularization)
//            Review and contribute to Android codebases
//            Guide teams on React Native / Flutter feasibility and trade-offs
//            Ensure performance, security, and production readiness
//            Mentor junior engineers and lead code reviews
//
//            ✅ Requirements:
//            4–6 years of mobile app development experience
//            Strong expertise in Swift, UIKit, SwiftUI
//            Hands-on experience with Android (Kotlin preferred)
//            Working knowledge of React Native or Flutter
//            Experience with production-scale apps
//            Strong ownership and problem-solving mindset
//
//            ✨ Why Join Nickelfox?
//            Work on real-world, scalable mobile products
//            High ownership and real technical influence
//            Opportunity to grow into staff-level or architectural roles
//
//            📩 Interested?
//            Share your resume at careers@niceklfox.com
//             or tag someone who’d be a great fit!
//            Shraddha Shrivastava Shivani Sharma Sweeti Kumari
//            """,
//        rawDescription: """
//            🚀 We’re Hiring: SDE 4 – Mobile Application Developer
//            📍 Location: Noida (Work From Office)
//            🕒 Experience: 4–6 Years | Full-time
//
//            Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4) with deep expertise in native iOS development and solid exposure to Android and cross-platform frameworks (React Native / Flutter).
//
//            This role is for engineers who think beyond features and care about architecture, performance, scalability, and clean code.
//
//            🔧 Key Responsibilities:
//            Own end-to-end development of complex mobile features (primarily iOS)
//            Design and evolve mobile architecture (MVVM, Clean Architecture, modularization)
//            Review and contribute to Android codebases
//            Guide teams on React Native / Flutter feasibility and trade-offs
//            Ensure performance, security, and production readiness
//            Mentor junior engineers and lead code reviews
//
//            ✅ Requirements:
//            4–6 years of mobile app development experience
//            Strong expertise in Swift, UIKit, SwiftUI
//            Hands-on experience with Android (Kotlin preferred)
//            Working knowledge of React Native or Flutter
//            Experience with production-scale apps
//            Strong ownership and problem-solving mindset
//
//            ✨ Why Join Nickelfox?
//            Work on real-world, scalable mobile products
//            High ownership and real technical influence
//            Opportunity to grow into staff-level or architectural roles
//
//            📩 Interested?
//            Share your resume at careers@niceklfox.com
//             or tag someone who’d be a great fit!
//            Shraddha Shrivastava Shivani Sharma Sweeti Kumari
//            """,
//        hrEmail: "careers@niceklfox.com",
//        url: "https://www.linkedin.com/posts/seema-diwakr_hiring-mobiledeveloper-iosdeveloper-activity-7415252598548533248-wJgr?utm_medium=ios_app&rcm=ACoAAEGjvOcBLTgyu3-MZbOsl3rWuk8KALWdhqA&utm_source=social_share_send&utm_campaign=share_via"),
//                    tone: .professional,
//                    prompt: "Hey")
//}
