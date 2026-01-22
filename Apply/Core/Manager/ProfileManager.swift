//
//  ProfileManager.swift
//  Apply
//
//  Created by Pranjal Verma on 20/01/26.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor // UI/Database work happens on Main Thread
class ProfileManager {
    static let shared = ProfileManager()
    
    private init() {}
    
    // This is the function BOTH Onboarding and Settings will call
    func processNewResume(url: URL, context: ModelContext) async throws {
        print("🔄 Starting Resume Processing...")
        
        // 1. Save the File
        try CVManager.shared.saveCV(from: url)
        
        // 2. Extract Text
        guard let savedURL = CVManager.shared.cvURL,
              let rawText = PDFTextExtractor.shared.extractText(from: savedURL) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        // 3. AI Extraction
        let aiResponse = try await AIService.shared.extractProfile(resumeText: rawText)
        
        // 4. Update Database (Your "Delete & Replace" Logic)
        // Clear old profile
        try? context.delete(model: UserProfile.self)
        
        // Create new profile
        let newProfile = UserProfile(
            name: aiResponse.name,
            email: aiResponse.email,
            phoneNumber: aiResponse.phone,
            experience: aiResponse.experience,
            skills: aiResponse.skills
        )
        
        context.insert(newProfile)
        try context.save()
        
        print("✅ SUCCESS: Profile Updated for \(newProfile.name)")
    }
}
