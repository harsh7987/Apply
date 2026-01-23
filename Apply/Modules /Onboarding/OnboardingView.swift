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
    var onFinish: () -> Void
    @State private var viewmodel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query var user: [UserProfile]
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                OBSubHeadline()
                ForEach(viewmodel.onBoardingItems) { data in
                    OnboardingCommonView(data: data) {
                        getItemView(for: data)
                    }
                }
                
                if let error = viewmodel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
                nextButton
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
        
    }
    
    var nextButton: some View {
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // ℹ️ 1. The Info Button (User Manual)
                    Button {
                        viewmodel.showInfoAlert = true
                        FeedbackManager.shared.impact(.light)
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial) // Glass effect
                            .clipShape(Circle())
                    }
                    .alert("How it works", isPresented: $viewmodel.showInfoAlert) {
                        Button("Got it", role: .cancel) { }
                    } message: {
                        Text("Upload your resume and our AI will automatically extract your details to fill your profile. You can then review and edit the information.")
                    }
                    
                    // ➡️ 2. The Next Button (Conditional)
                    Button {
                        FeedbackManager.shared.impact(.medium)
                        viewmodel.showReviewSheet.toggle()
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "arrow.forward")
                        }
                        .frame(maxWidth: .infinity) // Make it fill the remaining space
                        // 🎨 Apply specific style manually instead of .greenCardStyle() for better control here
                        .font(.title3.bold())
                        .padding()
                        .background(viewmodel.uploadSucces ? Color.primary : Color.gray.opacity(0.3)) // Green/Black if active, Gray if disabled
                        .foregroundStyle(viewmodel.uploadSucces ? Color(uiColor: .systemBackground) : Color.gray) // Text color
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    // 🔒 Disable until Resume is Uploaded
                    .disabled(!viewmodel.uploadSucces)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    
    @ViewBuilder
    func getItemView(for data: OnboardingItem) -> some View {
        switch data.type {
        case .resume:
            resumeButton
        case .coverLetter:
            coverLetterButton
        }
    }
    
    var resumeButton: some View {
        Button {
            viewmodel.importResume.toggle()
        } label: {
            HStack {
                // Change Text based on State
                if viewmodel.isExtracting {
                    ProgressView()
                } else if viewmodel.uploadSucces {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Text("Upload")
                }
            }
            .buttonDesign()
        }
        .disabled(viewmodel.isExtracting || viewmodel.uploadSucces)
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
    }
    
    var coverLetterButton: some View {
        Button {
            print("Import cover letter \(viewmodel.importCover)")
            viewmodel.importCover.toggle()
        } label: {
            HStack {
                if viewmodel.isCoverUploaded {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Text("Upload")
                }
            }
            .buttonDesign()
        }
        .fileImporter(isPresented: $viewmodel.importCover,
                      allowedContentTypes: [.pdf],
                      allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    // ✅ Wrap in do-catch to handle errors safely
                    do {
                        try CoverLetterManager.shared.saveCoverLetter(from: url)
                        
                        // Update UI immediately
                        viewmodel.isCoverUploaded = true
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
    
    //    @ViewBuilder
    //    func connectEmailButton() -> some View {
    //        Button {
    //            viewmodel.saveAllData()
    //        } label: {
    //            Text("Upload")
    //                .buttonDesign()
    //        }
    //    }
}

#Preview {
    OnboardingView { }
}
