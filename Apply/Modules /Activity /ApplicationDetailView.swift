//
//  ApplicationDetailView.swift
//  Apply
//
//  Created by Pranjal Verma on 12/01/26.
//

import SwiftUI
internal import MessageUI
import SwiftData

struct ApplicationDetailView: View {
    // 1. DATA SOURCE
    let application: JobApplication
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // 2. STATE FOR TABS
    @State private var selectedTab = 0
    
    // 3. LOGIC STATES (From Old View)
    @State private var showRefineView = false
    @State private var showManualFollowUpComposer = false
    @State private var manualFollowUpResult: ComposeResult?
    @State private var showNoMailAlert = false
    
    // 4. COMPUTED PROPS
    var isUrgent: Bool {
        application.followUpDate < Date()
    }
    
    var body: some View {
        ZStack {
            // A. BACKGROUND (Deep Terminal Void)
            if colorScheme == .dark {
                Color(hex: "050505").ignoresSafeArea()
            } else {
                Color(red: 0.97, green: 0.97, blue: 0.98).ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                
                // 1. CUSTOM NAV BAR
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding(10)
                            .background(Material.ultraThin)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(application.companyName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    // Invisible spacer to balance the back button
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 2. STATUS DOSSIER CARD
                        StatusDossierCard(app: application, isUrgent: isUrgent)
                        
                        // 3. SEGMENTED CONTROL
                        GlassSegmentedControl(selectedTab: $selectedTab)
                        
                        // 4. CONTENT AREA
                        if selectedTab == 0 {
                            EmailBodyContent(app: application)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            JobIntelContent(app: application)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 140) // Space for floating button
                }
            }
            
            // 5. BOTTOM COMMAND BAR (Dynamic Button)
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Gradient Fade to blend content behind button
                    LinearGradient(colors: [.clear, colorScheme == .dark ? .black.opacity(0.8) : .white.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 30)
                    
                    ZStack {
                        colorScheme == .dark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                        
                        // THE DYNAMIC ACTION BUTTON
                        Button(action: handleFollowUpAction) {
                            HStack(spacing: 12) {
                                Image(systemName: isUrgent ? "bell.badge.fill" : "paperplane.fill")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Text(getButtonLabel())
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(isUrgent ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                // DYNAMIC GRADIENT LOGIC
                                LinearGradient(
                                    colors: getButtonGradient(),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: isUrgent
                                ? Color(hex: "FFA500").opacity(0.5)
                                : Color.blue.opacity(0.4),
                                radius: 15, x: 0, y: 5
                            )
                            // Pulse Animation if Urgent
                            .overlay(
                                Group {
                                    if isUrgent {
                                        Capsule()
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                            .blendMode(.overlay)
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }
                    .frame(height: 80)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        .toolbar(.hidden, for: .tabBar) // Hide Tab Bar to focus
        .navigationBarBackButtonHidden(true)
        // --- LOGIC HANDLERS ---
        
        // A. Manual Email Sheet
        .sheet(isPresented: $showManualFollowUpComposer) {
            MailComposerView(
                result: $manualFollowUpResult,
                subject: "Following up: \(application.generatedSubject)",
                genratedBody: "\n\nBest,\n[Your Name]",
                recipients: [application.hrEmail ?? ""],
                attachmentURL: CVManager.shared.cvURL,
                coverLetterURL: CoverLetterManager.shared.coverLetterURL
            )
        }
        // B. Update Logic for Manual Email
        .onChange(of: manualFollowUpResult) { _, newValue in
            if case .success(.sent) = newValue {
                application.markFollowUpSent(context: modelContext)
            }
        }
        // C. 🛡️ MAIL CRASH PREVENTER ALERT
        .alert("Mail Not Configured", isPresented: $showNoMailAlert) {
            // Provide a helpful fallback so the user isn't stuck
            Button("Copy Email Body") {
                UIPasteboard.general.string = application.generatedBody
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please set up the Apple Mail app to send emails, or copy the draft to your clipboard to send it from another app like Gmail.")
        }
        // D. AI Refinement Navigation
        .navigationDestination(isPresented: $showRefineView) {
            RefineEmailView(
                existingDraft: application,
                tone: .formal,
                prompt: "Write a short follow-up email for this position.",
                isFollowUpMode: true
            )
        }
    }
    
    // --- HELPER FUNCTIONS ---
    
    func handleFollowUpAction() {
        if application.applicationMethod == .manualEmail {
            if MFMailComposeViewController.canSendMail() {
                showManualFollowUpComposer = true
            } else {
                showNoMailAlert = true
            }
        } else {
            showRefineView = true
        }
    }
    
    func getButtonLabel() -> String {
        if isUrgent { return "Send Follow-Up Now" }
        if application.applicationMethod == .manualEmail { return "Write Manual Follow-Up" }
        return "Draft AI Follow-Up"
    }
    
    func getButtonGradient() -> [Color] {
        if isUrgent {
            return [Color(hex: "FFD700"), Color(hex: "FFA500")] // LIQUID GOLD (Urgent)
        }
        if application.applicationMethod == .manualEmail {
            return [Color.green, Color.teal] // GREEN (Manual)
        }
        return [Color(hex: "007AFF"), Color(hex: "00C7BE")] // ELECTRIC BLUE (AI)
    }
}

// =========================================
// MARK: - SUB-VIEWS (Now using JobApplication)
// =========================================

// 1. STATUS DOSSIER CARD
struct StatusDossierCard: View {
    let app: JobApplication
    let isUrgent: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Hero Subject Line
            Text(app.generatedSubject)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider().overlay(Color.gray.opacity(0.3))
            
            // Data Grid
            VStack(spacing: 16) {
                DataRow(label: "Status", value: app.status, valueColor: .gray)
                DataRow(label: "Applied On", value: app.appliedDate.formatted(date: .abbreviated, time: .omitted), valueColor: colorScheme == .dark ? .white : .black)
                DataRow(label: "Sent To", value: app.hrEmail ?? "Unknown", valueColor: .gray, isEmail: true)
                
                // Alert Row
                DataRow(
                    label: "Next Follow-up",
                    value: isUrgent ? "Due Now" : app.followUpDate.formatted(.relative(presentation: .named)),
                    valueColor: isUrgent ? Color.red : Color.blue
                )
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(colorScheme == .dark ? Color(hex: "0B0B0C") : .white))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// 2. SEGMENTED CONTROL (Unchanged logic, just visuals)
struct GlassSegmentedControl: View {
    @Binding var selectedTab: Int
    @Namespace private var animationNamespace
    @Environment(\.colorScheme) var colorScheme
    let tabs = ["Application", "Job Intel"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: { selectedTab = index }) {
                    ZStack {
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1))
                                .matchedGeometryEffect(id: "ActiveTab", in: animationNamespace)
                        }
                        Text(tabs[index])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(selectedTab == index ? (colorScheme == .dark ? .white : .black) : .gray)
                            .padding(.vertical, 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 18).fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.05)))
    }
}

// 3. CONTENT TABS
struct EmailBodyContent: View {
    let app: JobApplication
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("GENERATED EMAIL BODY").font(.caption.bold()).foregroundStyle(.gray).tracking(1)
                Spacer()
                Button(action: { UIPasteboard.general.string = app.generatedBody }) {
                    Image(systemName: "doc.on.doc").font(.caption).foregroundStyle(.blue)
                }
            }
            Text(app.generatedBody)
                .font(.system(size: 16))
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.85))
                .lineSpacing(5)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(colorScheme == .dark ? Color.white.opacity(0.03) : .white))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct JobIntelContent: View {
    let app: JobApplication
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            if let url = URL(string: app.url) {
                Link(destination: url) {
                    HStack { Text("View Original Listing"); Spacer(); Image(systemName: "arrow.up.right") }
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(.blue)
                        .padding(16).background(Color.blue.opacity(0.1)).cornerRadius(16)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("JOB DESCRIPTION").font(.caption.bold()).foregroundStyle(.gray).tracking(1)
                Text(app.jobDescription)
                    .font(.system(size: 15))
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                    .lineSpacing(5)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(colorScheme == .dark ? Color.white.opacity(0.03) : .white))
        }
    }
}

// 4. DataRow Helper
struct DataRow: View {
    let label: String
    let value: String
    let valueColor: Color
    var isEmail: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.gray)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: isEmail ? .regular : .semibold))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .truncationMode(.middle)
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
