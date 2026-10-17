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
    var showReviewSheet = false
    
    // CoverLetter
    var importCover = false
    var isCoverUploaded = false
    
    // CV
    var importResume = false
    var isExtracting = false
    var uploadSucces = false
    var errorMessage: String?
    
    // Add this state to handle the Info Popup
    var showInfoAlert = false
    
    // Info
    var showInfoSheet = false
    
    
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

