//
//  JobPreviewView.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

// Modules/JobPreviewView.swift
import SwiftUI
import SwiftData

// 1. Define the Tones available
enum ToneOption: String, CaseIterable, Identifiable {
    case casual = "Casual"
    case professional = "Professional"
    case formal = "Formal"
    case short = "Short"
    var id: String { self.rawValue }
}

struct JobPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var users: [UserProfile]
    var originalJob: ScrapedJob
    
    // Job Data States (Editable)
    @State var title: String
    @State var description: String
    @State var email: String
    
    // --- NEW STATES ---
    @State private var selectedTone: ToneOption = .professional
    @State private var userPrompt: String = ""
    let promptLimit = 100
    
    // Navigation State
    @State private var navigateToRefine = false
    
    init(job: ScrapedJob) {
        self.originalJob = job
        _title = State(initialValue: job.title)
        _description = State(initialValue: job.cleanDescription)
        _email = State(initialValue: job.hrEmail ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // =========================================
                // MARK: Tone Selection
                // =========================================
                Section("Choose your tone") {
                    Picker("Tone", selection: $selectedTone) {
                        ForEach(ToneOption.allCases) { tone in
                            Text(tone.rawValue).tag(tone)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
                
                // =========================================
                // MARK: AI Prompt
                // =========================================
                Section(header: Text("AI Instructions (Optional)"),
                        footer: HStack {
                    Spacer()
                    Text("\(userPrompt.count)/\(promptLimit) characters")
                }) {
                    
                    TextField("e.g., Mention my SwiftUI experience...", text: $userPrompt, axis: .vertical)
                        .lineLimit(2...3)
                        .onChange(of: userPrompt) { _, newValue in
                            if newValue.count > promptLimit {
                                userPrompt = String(newValue.prefix(promptLimit))
                            }
                        }
                }
                
                // =========================================
                // MARK: Job Data (Editable)
                // =========================================
                Section("Job Details") {
                    TextField("Job Title", text: $title)
                        .font(.headline)
                    TextField("HR Email (Optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .foregroundStyle(.secondary)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 250)
                        .font(.callout)
                }
                
                // =========================================
                // MARK: NEXT BUTTON
                // =========================================
                Section {
                    Button {
                        // Just trigger navigation
                        FeedbackManager.shared.impact(.heavy)
                        navigateToRefine = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Next: Generate & Review")
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .tint(.blue)
                    .listRowBackground(Color.blue.opacity(0.1))
                }
            }
            .navigationTitle("Review & Personalize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            // =========================================
            // MARK: NAVIGATION HANDOFF
            // =========================================
            .navigationDestination(isPresented: $navigateToRefine) {
                // 1. Pack the edited data into a struct
                let editedJob = ScrapedJob(
                    title: title,
                    cleanDescription: description,
                    rawDescription: originalJob.rawDescription,
                    hrEmail: email,
                    url: originalJob.url
                )
                
                // 2. Pass everything to the Refine View (which creates the AI call)
                RefineEmailView(
                    job: editedJob,
                    tone: selectedTone,
                    prompt: userPrompt
                )
            }
        }
    }
}


#Preview {
    JobPreviewView(job:
                    ScrapedJob(
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
                        url: "https://www.linkedin.com/posts/seema-diwakr_hiring-mobiledeveloper-iosdeveloper-activity-7415252598548533248-wJgr?utm_medium=ios_app&rcm=ACoAAEGjvOcBLTgyu3-MZbOsl3rWuk8KALWdhqA&utm_source=social_share_send&utm_campaign=share_via")
    )
}
