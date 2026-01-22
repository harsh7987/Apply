//
//  ApplicationDetailView.swift
//  Apply
//
//  Created by Pranjal Verma on 12/01/26.
//

import SwiftUI
internal import MessageUI

struct ApplicationDetailView: View {
    let application: JobApplication
    @State private var showRefineView = false
    @Environment(\.modelContext) private var modelContext
    
    // Add state for Manual Follow-up
    @State private var showManualFollowUpComposer = false
    @State private var manualFollowUpResult: ComposeResult?
    
    var body: some View {
        List {
            // MARK: - Section 1: Status & Info
            Section("Status") {
                LabeledContent("Status", value: application.status)
                LabeledContent("Applied On", value: application.appliedDate.formatted(date: .abbreviated, time: .omitted))
                if let email = application.hrEmail {
                    LabeledContent("Sent To", value: email)
                }
                LabeledContent("Next Follow-up") {
                    if application.followUpDate < Date() {
                        Text("Due Now")
                            .foregroundStyle(.red)
                            .bold()
                    } else {
                        Text(application.followUpDate, style: .relative) // "in 6 days"
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            // MARK: - Section 2: AI Generated Letter
            Section("Generated Email Body") {
                VStack(alignment: .leading) {
                    Text(application.generatedSubject)
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    Divider()
                    
                    // Scrollable area for the Email Body
                    ScrollView {
                        Text(application.generatedBody)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 300) // 👈 Fixed Height as requested
                }
            }
            
            // MARK: - Section 3: Job Description
            Section("Job Description") {
                // Scrollable area for the Original Description
                ScrollView {
                    Text(application.jobDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 300) // 👈 Fixed Height as requested
            }
            
            // MARK: - Section 4: Actions
            Section {
                Button(action: {
                    UIPasteboard.general.string = application.generatedBody
                }) {
                    Label("Copy Email Body", systemImage: "doc.on.doc")
                }
                
                if let url = URL(string: application.url) { // Replace with application.jobUrl if added to model
                    Link(destination: url) {
                        Label("View Original Listing", systemImage: "arrow.up.right.square")
                    }
                }
            }
            
            // 🚀 The Follow-Up Button
            if application.applicationMethod == .manualEmail {
                Button {
                    showManualFollowUpComposer = true
                } label: {
                    Label("Write Follow-Up (Manual)", systemImage: "envelope.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green) // Green to distinguish?
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    showRefineView = true
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send Follow-Up Email")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationTitle(application.companyName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showManualFollowUpComposer) {
            MailComposerView(
                result: $manualFollowUpResult,
                subject: "Following up: ",
                genratedBody: "\n\nBest,\n[Your Name]", // Empty template
                recipients: [application.hrEmail ?? ""],
                attachmentURL: CVManager.shared.cvURL,
                coverLetterURL: CoverLetterManager.shared.coverLetterURL
            )
        }
        // 🆕 Listener for Manual Follow-Up Success
        .onChange(of: manualFollowUpResult) { _, newValue in
            if case .success(.sent) = newValue {
                application.markFollowUpSent(context: modelContext)
            }
        }
        
        .navigationDestination(isPresented: $showRefineView) {
            RefineEmailView(
                existingDraft: application,
                tone: .formal, // Follow-ups are usually formal
                prompt: "Write a short follow-up email for this position.",
                isFollowUpMode: true
            )
        }
    }
}

#Preview {
    var sample = JobApplication(
        companyName: "Unknown Company", jobTitle: "Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4)",
        jobDescription: """
        🚀 We’re Hiring: SDE 4 – Mobile Application Developer
        📍 Location: Noida (Work From Office)
        🕒 Experience: 4–6 Years | Full-time
        
        Nickelfox Technologies is looking for a Senior Mobile Engineer (SDE 4) with deep expertise in native iOS development and solid exposure to Android and cross-platform frameworks (React Native / Flutter).
        
        This role is for engineers who think beyond features and care about architecture, performance, scalability, and clean code.
        """ ,
        hrEmail: "careers@niceklfox.com",
        generatedSubject: "SDE 4 – Mobile Application Developer",
        generatedBody: """
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
            """, url: "https//:url"
    )
    
    ApplicationDetailView(application: sample)
    
}
