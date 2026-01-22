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
    @Environment(\.modelContext) private var modelContext
    @Query var users: [UserProfile]
    @AppStorage("useDefaultTemplates") private var useDefaultTemplates = false
    @Query private var templates: [UserTemplate]
    
    @State private var showCoverImporter = false
    
    @State private var showCVImporter = false
    @State private var isCVUpdating = false // 🌀 Spinner State
    @State private var alertMessage: String?
    @State private var showEditProfile = false
    
    private var templatesCount: Int {
        templates.count
    }
    
    var body: some View {
        List {
            // Section 1:
            Section(header: Text("ACCOUNT")) {
                
                // 1. Edit Profile (Replaces "Email Account")
                Button {
                    FeedbackManager.shared.impact(.light)
                    showEditProfile = true
                } label: {
                    SettingsRow(icon: "person.crop.circle.fill", color: .green, title: "Edit Profile", value: users.first?.name ?? "User")
                }
                
                // 2. Resume & Cover Letter
                Button {
                    showCVImporter = true
                } label: {
                    HStack {
                        SettingsRow(icon: "doc.fill", color: .orange, title: "Resume",
                                    value: CVManager.shared.cvExists() ? "Uploaded" : "Upload")
                        
                        if isCVUpdating {
                            Spacer()
                            ProgressView()
                                .padding(.leading, 5)
                        }
                    }
                }
                .disabled(isCVUpdating)
             // Cover button
                Button {
                    showCoverImporter = true
                } label: {
                    HStack {
                        SettingsRow(icon: "text.quote", color: .purple, title: "Cover Letter", value: CoverLetterManager.shared.coverLetterExists() ? "Uploaded" : "Upload")
                    }
                }
                
            }
            
            // Section 2:
            useDefault
            
            // Section 2: Preferences
            Section(header: Text("PREFERENCES")) {
                SettingsRow(icon: "textformat", color: .blue, title: "Default Tone", value: "Professional")
                SettingsRow(icon: "chart.bar.fill", color: .blue, title: "Daily Limit", value: "3/4 remaining")
            }
            
            // Section 3: Subscription Banner
            Section(header: Text("SUBSCRIPTION")) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading) {
                        Text("Free Plan").bold()
                        Text("Upgrade for unlimited drafts").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Upgrade") { }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 4)
            }
            
            // Section 4: Data
            Section(header: Text("DATA")) {
                SettingsRow(icon: "lock.fill", color: .gray, title: "Privacy & Data", value: "")
            }
        }
        .navigationTitle("Settings")
        .fileImporter(
            isPresented: $showCVImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleResumeSelection(result)
        }
        // Error/Success Alert
        .alert("Resume Update", isPresented: Binding(get: { alertMessage != nil }, set: { _ in alertMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = users.first {
                NavigationStack {
                    ProfileEditView(user: user, isOnboarding: false)
                }
            } else {
                ContentUnavailableView(
                    "No Profile Found",
                    systemImage: "person.slash",
                    description: Text("Please complete onboarding first.")
                )
            }
        }
        // Cover
        .fileImporter(isPresented: $showCoverImporter,
                      allowedContentTypes: [.pdf],
                      allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    // ✅ Wrap in do-catch to handle errors safely
                    do {
                        try CoverLetterManager.shared.saveCoverLetter(from: url)
                        
                        FeedbackManager.shared.trigger(.success)
                        print("✅ Cover letter saved successfully.")
                    } catch {
                        print("❌ Failed to save file: \(error.localizedDescription)")
                        FeedbackManager.shared.trigger(.error)
                    }
                }
            case .failure(let error):
                print("❌ Import failed: \(error.localizedDescription)")
            }
        }
        
    }
    
    var useDefault: some View {
        Section(header: Text("Application Method")) {
            Toggle("Use Custom Templates", isOn: $useDefaultTemplates)
                .tint(.green)
                .onChange(of: useDefaultTemplates) { oldValue, newValue in
                        FeedbackManager.shared.impact(.light)
                    }
            
            if useDefaultTemplates {
                NavigationLink(destination: DetailDefaultListView()) {
                    HStack {
                        Text("Manage Templates")
                        Spacer()
                        Text("\(templatesCount) Saved")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // The Logic Function
    private func handleResumeSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // 🔒 Security Access is critical here
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Start the heavy work
                isCVUpdating = true
                
                Task {
                    do {
                        // 📞 Call the Shared Manager
                        try await ProfileManager.shared.processNewResume(url: url, context: modelContext)
                        
                        await MainActor.run {
                            isCVUpdating = false
                            alertMessage = "Resume processed! Your profile skills have been updated."
                        }
                    } catch {
                        await MainActor.run {
                            isCVUpdating = false
                            alertMessage = "Failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
        }
    }
    
}

struct SettingsRow: View {
    var icon: String
    var color: Color
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30) // Fixed width for alignment
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    SettingsView()
}
