//
//  GenerationRequest.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

import Foundation

// The "Bundle" that travels to the AI
struct GenerationRequest {
    let user: UserProfile        // Your existing SwiftData model
    let job: ScrapedJob          // From the Scraper
    let tone: ToneOption         // From the UI Picker
    let userPrompt: String       // From the UI Textfield (Optional instructions)
}
