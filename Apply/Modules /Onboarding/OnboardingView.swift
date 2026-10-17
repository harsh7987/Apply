//
//  OnboardingView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    var onFinish: () -> Void
    @State private var viewmodel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query var user: [UserProfile]
    
    var body: some View {
        ZStack {
            LiquidDarkBackground(variant: 2)
            VStack(spacing: 0) {
                infoView
                Spacer()
                VStack(spacing: 40) {
                    OBSubHeadline()
                    VStack(spacing: 20) {
                        // --- RESUME CARD ---
                        MyraDataCartridge(
                            title: "Resume Core",
                            subtitle: "PDF / DocX",
                            // PASSING YOUR LOGIC DIRECTLY 👇
                            isLoading: viewmodel.isExtracting,
                            isComplete: viewmodel.uploadSucces,
                            action: {
                                viewmodel.importResume = true
                            }
                        )
                        .fileImporter(isPresented: $viewmodel.importResume,
                                      allowedContentTypes: [.pdf],
                                      allowsMultipleSelection: false) { result in
                            switch result {
                            case .success(let url):
                                if let url = url.first {
                                    
                                    Task {
                                        await viewmodel.processSelectResume(resumeURL: url, modelContext: modelContext)
                                    }
                                }
                            case .failure(let failure):
                                viewmodel.errorMessage = failure.localizedDescription
                            }
                            
                        }
                        // --- COVER LETTER CARD ---
                        MyraDataCartridge(
                            title: "Tone Module",
                            subtitle: "Optional Cover Letter",
                            isLoading: false, // Cover letter has no loading state in your VM yet
                            isComplete: viewmodel.isCoverUploaded,
                            action: {
                                viewmodel.importCover = true
                            }
                        )
                        .fileImporter(isPresented: $viewmodel.importCover,
                                      allowedContentTypes: [.pdf],
                                      allowsMultipleSelection: false) { result in
                            switch result {
                            case .success(let urls):
                                if let url = urls.first {
                                    try? CoverLetterManager.shared.saveCoverLetter(from: url)
                                    viewmodel.isCoverUploaded = true
                                }
                            case .failure(let failure):
                                viewmodel.errorMessage = failure.localizedDescription
                            }
                        }
                        
                    }
                    .padding(.horizontal, 24)
                }
                Spacer()
                
                // --- ERROR BLOCK ---
                if let error = viewmodel.errorMessage {
                    HolographicWarning(text: error)
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .onTapGesture {
                            // Optional: Tap to dismiss locally if you want
                            withAnimation { viewmodel.errorMessage = nil }
                        }
                }
                
                Button {
                    FeedbackManager.shared.impact(.medium)
                    viewmodel.showReviewSheet.toggle()
                } label: {
                    HStack(spacing: 12) {
                        if viewmodel.uploadSucces {
                            Image(systemName: "power").font(.system(size: 20, weight: .bold))
                        }
                        Text(viewmodel.uploadSucces ? "IGNITE SYSTEM" : "AWAITING CORE")
                            .font(.system(size: 16, weight: .heavy))
                            .tracking(1)
                    }
                    .foregroundStyle(viewmodel.uploadSucces ? .black : .gray.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        ZStack {
                            if viewmodel.uploadSucces {
                                LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .leading, endPoint: .trailing)
                            } else {
                                RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            }
                        }
                    )
                    .clipShape(Capsule())
                }
                .disabled(!viewmodel.uploadSucces)
                .padding(24)
            }
            
        }
        .onAppear {
            viewmodel.checkUploadStatus()
        }
        .sheet(isPresented: $viewmodel.showReviewSheet) {
            if let user = user.first {
                NavigationStack {
                    ProfileEditView(user: user, isOnboarding: true) {
                        onFinish()
                    }
                }
            }
        }
        // Info about onBoarding
        .sheet(isPresented: $viewmodel.showInfoSheet) {
            IntelligenceBriefingSheet()
                .presentationDetents([.fraction(0.65)]) // Takes up 40% of screen
                .presentationDragIndicator(.visible)
        }
    }
    
     var infoView: some View {
        HStack {
            Spacer()
            Button(action: { viewmodel.showInfoSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan)
                    Text("Why is this required?")
                }
                .font(.caption.bold())
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Material.ultraThin)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        LinearGradient(colors: [.cyan.opacity(0.3), .purple.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 1
                    )
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)

    }
    
}

struct HolographicWarning: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            
            Text(text)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.2)) // Red Glass
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.5), lineWidth: 1) // Red Border
        )
        .shadow(color: .red.opacity(0.3), radius: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    OnboardingView { }
}
