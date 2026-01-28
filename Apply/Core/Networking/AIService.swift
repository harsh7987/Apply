//
//  AIService.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

import Foundation

class AIService {
    static let shared = AIService()
    private let apiKey = "sk-proj-1uVtC6MNkgPyEkcFS3MUwvQkjRLmtkkdA56Lv4DPlkk7PkwIaHTV3_mhrMY38wAzt3qFTIOr6gT3BlbkFJtVa-TUUFYZLPgasalP5VSOJYxVxQ9Mr-X2XIpmf4CCdOLcwcdk4XTxFSfKnh6hqyRoskU0z"
    
    // 1. Generate Letter
    func generateCoverLetter(request: GenerationRequest) async throws -> GeneratedCoverLetter {
        print("🤖 Generating Letter...")
        return try await performAICall(
            route: .generateApplication(apiKey: apiKey, request: request),
            resultType: GeneratedCoverLetter.self
        )
    }
    
    // 2. Extract Profile
    func extractProfile(resumeText: String) async throws -> AIProfileResponse {
        print("📄 Extracting Resume Data...")
        return try await performAICall(
            route: .extractProfile(apiKey: apiKey, resumeText: resumeText),
            resultType: AIProfileResponse.self
        )
    }
    
    // Generic Helper to handle the "Double Decoding" for any AI Call
    private func performAICall<T: Codable>(route: RestApi, resultType: T.Type) async throws -> T {
        // A. Call Network
        let openAIData = try await NetworkManager.shared.callAPI(
            request: route,
            responseType: OpenAIModels.self
        )
        
        // B. Extract String Content
        guard let contentString = openAIData.choices.first?.message.content else {
            throw URLError(.cannotParseResponse)
        }
        
        // C. Decode Inner JSON
        guard let rawData = contentString.data(using: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        return try JSONDecoder().decode(T.self, from: rawData)
    }
}
