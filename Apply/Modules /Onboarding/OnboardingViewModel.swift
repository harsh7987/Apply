//
//  OnboardingViewModel.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI
import SwiftData

@Observable
class OnboardingViewModel {
    
    var onBoardingItems: [OnboardingItem] = []
    var isPresentHomeView = false
    var showReviewSheet = false
    
    // CoverLetter
    var importCover = false
    var isCoverUploaded = false
    
    // CV
    var importResume = false
    var isExtracting = false
    var uploadSucces = false
    var errorMessage: String?
    
    var resume = OnboardingItem(imageName: "text.document.fill", title: "Upload Resume", subHeading: "PDF or DocX", type: .resume)
    var letter = OnboardingItem(imageName: "long.text.page.and.pencil.fill", title: "Cover Latter", subHeading: "Optional for tone matching", type: .coverLetter)
    
    
    init() {
        loadData()
    }
    
    func loadData() {
        onBoardingItems = [resume, letter]
    }
    
    func performAction(data: OnboardingItemType) {
        switch data {
        case .coverLetter:
            print("latter ")
        case .resume:
            print("Resume")
        }
    }
    
    @MainActor
    func processSelectResume(resumeURL: URL, modelContext: ModelContext) async {
        
        isExtracting = true
        errorMessage = nil
        
        do {
            // 2. Delegate the heavy work to the Manager! 🤝
            try await ProfileManager.shared.processNewResume(url: resumeURL, context: modelContext)
            
            // 3. Handle Success (Onboarding specific logic)
            print("✅ VM: Manager finished. Moving to Review.")
            uploadSucces = true
            FeedbackManager.shared.trigger(.success)
            
            // Small delay for UX
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
            showReviewSheet = true
            
        } catch {
            // 4. Handle Errors
            print("❌ VM Error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isExtracting = false
    }
    
    func checkUploadStatus() {
        // 1. Check Resume
        self.uploadSucces = CVManager.shared.cvExists()
        
        // 2. Check Cover Letter
        self.isCoverUploaded = CoverLetterManager.shared.coverLetterExists()
    }
    
}

