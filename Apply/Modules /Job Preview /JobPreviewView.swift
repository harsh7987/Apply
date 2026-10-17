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
    // 1. ENVIRONMENT & DATA
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    // 2. CORE DATA
    var originalJob: ScrapedJob
    
    // 3. EDITABLE STATE
    // We only need description here based on your request, but we keep title/email internally to pass them forward
    @State private var description: String
    @State private var selectedTone: ToneOption = .professional
    @State private var userPrompt: String = ""
    @State private var isDescriptionExpanded: Bool = false
    
    // 4. NAVIGATION STATE
    @State private var navigateToRefine = false
    @State private var showSubscription = false
    
    // 5. INIT (Crucial for data flow)
    init(job: ScrapedJob) {
        self.originalJob = job
        _description = State(initialValue: job.cleanDescription)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // A. BACKGROUND (Plasma Logic)
                PlasmaBackground(color: .blue)
                    .ignoresSafeArea()
                
                // B. SCROLLABLE CONTENT
                VStack(spacing: 0) {
                    
                    // 1. HEADER
                    VStack(spacing: 12) {
                        Capsule()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                        
                        HStack {
                            Text("Configuration")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Spacer()
                            
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.gray.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                    }
                    .background(Material.ultraThin)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 2. JOB INTELLIGENCE CARD (Glass Terminal)
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "doc.text.viewfinder")
                                        .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                                        .font(.title3)
                                    
                                    Text("Analyzed Description")
                                        .font(.headline)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    Spacer()
                                }
                                
                                Divider().overlay(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    // BINDING TO EDITABLE DESCRIPTION
                                    Text(description)
                                        .font(.system(size: 14))
                                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.75))
                                        .lineLimit(isDescriptionExpanded ? nil : 4)
                                        .animation(.easeInOut, value: isDescriptionExpanded)
                                    
                                    Button(action: { withAnimation { isDescriptionExpanded.toggle() } }) {
                                        HStack(spacing: 4) {
                                            Text(isDescriptionExpanded ? "Collapse" : "Expand Context")
                                                .font(.caption.bold())
                                            Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                                .font(.caption2.bold())
                                        }
                                        .foregroundStyle(.blue)
                                        .padding(.top, 4)
                                    }
                                }
                            }
                            .padding(20)
                            .background(ChromeGlassCard(color: .blue))
                            
                            // 3. TONE SELECTOR (Plasma Chips)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TARGET TONE")
                                    .font(.caption).fontWeight(.bold).tracking(1)
                                    .foregroundStyle(.gray).padding(.leading, 4)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(ToneOption.allCases) { tone in
                                            // Mapping your ToneOption to the Visual Crystal
                                            // We assume ToneCrystal accepts your enum directly or you map it
                                            ToneCrystal(tone: tone, isSelected: selectedTone == tone) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedTone = tone
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 4)
                                }
                            }
                            
                            // 4. INSTRUCTIONS (The Terminal)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("ADDITIONAL CONTEXT")
                                        .font(.caption).fontWeight(.bold).tracking(1)
                                        .foregroundStyle(.gray)
                                    Spacer()
                                    Text("\(userPrompt.count)/100") // Prompt Limit UI
                                        .font(.caption2).monospaced()
                                        .foregroundStyle(.gray)
                                }
                                .padding(.leading, 4)
                                
                                ZStack(alignment: .topLeading) {
                                    if userPrompt.isEmpty {
                                        Text("e.g., Emphasize my 3 years of SwiftUI experience...")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.gray.opacity(0.6))
                                            .padding(16)
                                            .padding(.top, 2)
                                    }
                                    
                                    TextEditor(text: $userPrompt)
                                        .font(.system(size: 15))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .scrollContentBackground(.hidden)
                                        .padding(12)
                                        .frame(minHeight: 120)
                                        .onChange(of: userPrompt) { _, newValue in
                                            if newValue.count > 100 {
                                                userPrompt = String(newValue.prefix(100))
                                            }
                                        }
                                }
                                .background(ChromeGlassCard(color: .gray))
                            }
                        }
                        .padding(20)
                        .padding(.bottom, 100)
                    }
                }
                
                // C. THE GENERATE BUTTON (Action Trigger)
                VStack {
                    Spacer()
                    Button(action: {
                        FeedbackManager.shared.impact(.heavy)
                        
                        if CreditManager.shared.activeWallet?.tokenBalance ?? 0 > 0 {
                                navigateToRefine = true // Let them through!
                            } else {
                                withAnimation(.spring()) {
                                    showSubscription = true // Stop them and show paywall
                                }
                            }
                        
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .bold))
                            
                            Text("Generate Application")
                                .font(.system(size: 16, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color(hex: "FFA500").opacity(0.4), radius: 20, x: 0, y: 10)
                                
                                // Diamond Shimmer (Light Mode Only)
                                if colorScheme == .light {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.clear)
                                        .overlay(
                                            LinearGradient(
                                                colors: [.clear, .white.opacity(0.8), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .frame(width: 60)
                                            .rotationEffect(.degrees(20))
                                            .offset(x: -90)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                        )
                        .overlay(
                            // Spinning Gradient Border Logic
                            GeometryReader { geo in
                                ZStack {
                                    AngularGradient(
                                        gradient: Gradient(colors: [.yellow, .red, .blue, .green, .cyan]),
                                        center: .center
                                    )
                                    .modifier(SpinEffect2(duration: 2))
                                    .frame(width: geo.size.width * 3, height: geo.size.width * 3)
                                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                    .mask(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(lineWidth: 3)
                                            .frame(width: geo.size.width, height: geo.size.height)
                                    )
                                }
                            }
                            .allowsHitTesting(false)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
                
                if showSubscription {
                    CrystalSubscriptionView(
                        isPresented: $showSubscription,
                        manager: CreditManager.shared
                    )
                    .zIndex(3)
                }
            }
            .navigationDestination(isPresented: $navigateToRefine) {
                // 1. Pack the edited data into a struct
                // We use the original job's title/email since we removed the textfields for them,
                // but we use the possibly edited 'description'.
                let editedJob = ScrapedJob(
                    title: originalJob.title,
                    cleanDescription: description, // <-- Edited Data
                    rawDescription: originalJob.rawDescription,
                    hrEmail: originalJob.hrEmail,
                    url: originalJob.url
                )
                
                // 2. Pass everything to the Refine View
                RefineEmailView(
                    job: editedJob,
                    tone: selectedTone,
                    prompt: userPrompt
                )
            }
        }
    }
}

struct SpinEffect2: ViewModifier {
    let duration: Double
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// 3. SUB-COMPONENTS & STYLES

// Reusable "Chrome/Plasma" Card Background (From your DashboardCard)
struct ChromeGlassCard: View {
    var color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(red: 0.05, green: 0.05, blue: 0.07).opacity(0.5)
            } else {
                Color.white.opacity(0.6)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            colorScheme == .dark ? .white.opacity(0.3) : .white,
                            colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.4),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// The Tone Selector Buttons (Plasma Chips)
struct ToneCrystal: View {
    let tone: ToneOption
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                }
                Text(tone.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(isSelected ? (colorScheme == .dark ? .white : .white) : (colorScheme == .dark ? .white : .black))
            .background(
                ZStack {
                    if isSelected {
                        // Active State: Blue Plasma
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .blue.opacity(0.4), radius: 8)
                    } else {
                        // Inactive: Glass
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// The Reusable Background Logic (Adapted from your DashboardCard)
struct PlasmaBackground: View {
    var color: Color
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base
            LinearGradient(
                colors: colorScheme == .dark
                ? [Color(red: 0.02, green: 0.02, blue: 0.03), Color(red: 0.05, green: 0.05, blue: 0.07)]
                : [Color(red: 0.95, green: 0.97, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.92)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            
            // Plasma Blobs
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color.blue.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: animate ? -100 : 100, y: animate ? -50 : 50)
                
                Circle()
                    .fill(colorScheme == .dark ? Color.purple.opacity(0.1) : Color.orange.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: animate ? 100 : -100, y: animate ? 50 : -50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// Helper for the Rotating Ring
struct RotateEffect: ViewModifier {
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation = 360
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
