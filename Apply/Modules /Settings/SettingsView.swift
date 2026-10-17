//
//  SettingsView.swift
//  Apply
//
//  Created by Pranjal Verma on 10/01/26.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    // 1. DATA & LOGIC CONNECTIONS
    @Query var users: [UserProfile]
    @Query private var templates: [UserTemplate]
    @AppStorage("useDefaultTemplates") private var useDefaultTemplates = false
    
    // 2. STATE MANAGEMENT
    var creditManager = CreditManager.shared
    @State var showSubscription = false
    
    // File Importers
    @State private var showCoverImporter = false
    @State private var showCVImporter = false
    
    // Alerts & Sheets
    @State private var alertMessage: String?
    @State private var showEditProfile = false
    
    private var templatesCount: Int { templates.count }
    
    var body: some View {
        ZStack {
            // A. BACKGROUND (Deep Void)
            if colorScheme == .dark {
                Color(hex: "050505").ignoresSafeArea()
            } else {
                Color(red: 0.97, green: 0.97, blue: 0.98).ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // 1. NAV BAR
                HStack(alignment: .center) {
                    Text("Control Center")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // 2. PROFILE HERO (Connected to Edit Sheet)
                        ProfileHero(user: users.first) {
                            FeedbackManager.shared.impact(.light)
                            showEditProfile = true
                        }
                        
                        // 3. FUEL GAUGE
                        UsageReactor(manager: creditManager)
                        
                        // 4. TITANIUM TOKEN CARD
                        TitaniumTokenCard(showSubscription: $showSubscription)
                        
                        // 5. CONFIGURATION MODULES
                        VStack(spacing: 20) {
                            
                            // SECTION: DOCUMENTS
                            SectionHeader(title: "DOCUMENTS")
                            VStack(spacing: 12) {
                                // RESUME TILE (With Logic & Spinner)
                                Button {
                                    showCVImporter = true
                                } label: {
                                    SettingsTile(
                                        icon: "doc.text.fill",
                                        color: .blue,
                                        title: "Resume",
                                        value: CVManager.shared.cvExists() ? "Updated" : "Upload"
                                    )
                                }
                                // 1. Resume Importer
                                .fileImporter(isPresented: $showCVImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                                    handleResumeSelection(result)
                                }
                                
                                // COVER LETTER TILE
                                Button {
                                    showCoverImporter = true
                                } label: {
                                    SettingsTile(
                                        icon: "text.quote",
                                        color: .purple,
                                        title: "Cover Letter",
                                        value: CoverLetterManager.shared.coverLetterExists() ? "Uploaded" : "Upload"
                                    )
                                }
                                // 2. Cover Letter Importer
                                .fileImporter(isPresented: $showCoverImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                                    handleCoverLetterSelection(result)
                                }
                            }
                            
                            // SECTION: PREFERENCES
                            SectionHeader(title: "PREFERENCES")
                            VStack(spacing: 12) {
                                SettingsTile(icon: "dial.low.fill", color: .orange, title: "Default Tone", value: "Professional")
                                
                                // TEMPLATE TOGGLE (Connected to AppStorage)
                                SettingsTile(
                                    icon: "switch.2",
                                    color: .green,
                                    title: "Use Custom Templates",
                                    isToggle: true,
                                    toggleBinding: $useDefaultTemplates
                                )
                                
                                // MANAGE TEMPLATES LINK (Conditional)
                                if useDefaultTemplates {
                                    NavigationLink(destination: DetailDefaultListView()) {
                                        SettingsTile(
                                            icon: "list.bullet.rectangle.portrait.fill",
                                            color: .gray,
                                            title: "Manage Templates",
                                            value: "\(templatesCount) Saved"
                                        )
                                    }
                                }
                            }
                            
                            // SECTION: SYSTEM
                            SectionHeader(title: "SYSTEM")
                            VStack(spacing: 12) {
                                SettingsTile(icon: "lock.fill", color: .gray, title: "Privacy & Data", value: "")
                                // SettingsTile(icon: "arrow.right.square.fill", color: .red, title: "Log Out", value: "", isDestructive: true)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                    }
                    .padding(.top, 10)
                }
            }
            
            // B. SUBSCRIPTION OVERLAY
            if showSubscription {
                CrystalSubscriptionView(isPresented: $showSubscription, manager: creditManager)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        // --- LOGIC HANDLERS ---
        // 1. Alerts
        .alert("Status", isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        // 2. Edit Profile Sheet
        .sheet(isPresented: $showEditProfile) {
            if let user = users.first {
                NavigationStack {
                    ProfileEditView(user: user, isOnboarding: false)
                }
            } else {
                ContentUnavailableView("No Profile Found", systemImage: "person.slash", description: Text("Please complete onboarding first."))
            }
        }
    }
    
    // --- LOGIC FUNCTIONS ---
    
    private func handleResumeSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                try CVManager.shared.saveCV(from: url)
                FeedbackManager.shared.trigger(.success)
                alertMessage = "Resume saved successfully."
            } catch {
                alertMessage = "Failed to save file: \(error.localizedDescription)"
                FeedbackManager.shared.trigger(.error)
            }
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    private func handleCoverLetterSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                do {
                    try CoverLetterManager.shared.saveCoverLetter(from: url)
                    FeedbackManager.shared.trigger(.success)
                    alertMessage = "Cover letter saved successfully."
                } catch {
                    alertMessage = "Failed to save file: \(error.localizedDescription)"
                    FeedbackManager.shared.trigger(.error)
                }
            }
        case .failure(let error):
            alertMessage = "Import failed: \(error.localizedDescription)"
        }
    }
}

// --- COMPONENT 1: TITANIUM TOKEN CARD (Fixed Button) ---
struct TitaniumTokenCard: View {
    @Binding var showSubscription: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background (Deep Metallic)
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2C2C2E"), Color(hex: "1C1C1E"), Color.black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                )
            
            // Content
            HStack(alignment: .center) {
                // Text Side
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "FFD700"))
                        Text("PRO ACCESS")
                            .font(.caption.bold())
                            .foregroundStyle(Color.gray)
                            .tracking(1)
                    }
                    
                    Text("Get More Tokens")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Text("Refill your daily fuel limit")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                // THE FIXED BUTTON (Compact & Integrated)
                Button(action: { showSubscription = true }) {
                    Text("Refill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "FFA500").opacity(0.4), radius: 8, x: 0, y: 4)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                .blendMode(.overlay)
                        )
                }
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// --- COMPONENT 2: USAGE REACTOR (Connected) ---
struct UsageReactor: View {
    var manager: CreditManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("DAILY FUEL")
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
                    .tracking(1)
                
                Text("\(manager.activeWallet?.tokenBalance ?? 0)  Tokens Available")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            
            Spacer()
            
            // The Reactor Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(manager.activeWallet?.tokenBalance ?? 0))
                    .stroke(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "bolt.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .cyan, radius: 5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(hex: "0B0B0C") : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}


// --- UPDATED COMPONENT: PROFILE HERO ---
struct ProfileHero: View {
    var user: UserProfile?
    var onEdit: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.gray.opacity(0.2)).frame(width: 70, height: 70)
                Text(String(getInitials(from: user?.name ?? "ME")).uppercased())
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Circle().strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [.cyan, .blue, .purple, .cyan]), center: .center),
                    lineWidth: 2
                ).frame(width: 70, height: 70)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user?.name ?? "Guest User").font(.title3.bold())
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(user?.experience ?? "Aspiring Developer").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onEdit) {
                Text("Edit")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color(hex: "2C2C2E") : Color(hex: "E5E5EA"))
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5), lineWidth: 1))
        .padding(.horizontal, 20)
    }
    
    // Get Initial Name Latter
    func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return name.prefix(2).uppercased()
    }
}

// --- UPDATED COMPONENT: SETTINGS TILE ---
struct SettingsTile: View {
    let icon: String; let color: Color; let title: String; var value: String = ""
    var isToggle: Bool = false
    var toggleBinding: Binding<Bool>? = nil // Optional binding for toggle
    var isDestructive: Bool = false
    
    @State private var animate = false
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 30, height: 30)
                Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            }
            Text(title).font(.system(size: 16, weight: .medium))
                .foregroundStyle(isDestructive ? .red : (colorScheme == .dark ? .white : .black))
            Spacer()
            
             if isToggle, let binding = toggleBinding {
                Toggle("", isOn: binding).labelsHidden().tint(color)
            } else {
                Text(value).font(.subheadline).foregroundStyle(.gray)
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            ZStack {
                LinearGradient(colors: getBaseColors(), startPoint: .topLeading, endPoint: .bottomTrailing)
                GeometryReader { proxy in
                    ZStack {
                        Circle().fill(color.opacity(0.1)).frame(width: 150, height: 150).blur(radius: 50)
                            .offset(x: animate ? -30 : 30, y: animate ? -10 : 10)
                    }
                }
            }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) { animate.toggle() }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        
    }
    
    func getBaseColors() -> [Color] {
        if colorScheme == .dark {
            return [Color(red: 0.03, green: 0.03, blue: 0.04), Color(red: 0.06, green: 0.06, blue: 0.08)]
        } else {
            return [Color(red: 0.95, green: 0.97, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.92)]
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack { Text(title).font(.caption.bold()).foregroundStyle(.gray).padding(.leading, 8); Spacer() }
    }
}


#Preview {
    SettingsView()
}
