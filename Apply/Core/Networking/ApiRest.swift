//
//  ApiRest.swift
//  ApiCalling
//
//  Created by Pranjal Verma on 04/01/26.
//

import Foundation


import Foundation

enum RestApi: NetworkRequest {
    
    // CASE 1: Generate Cover Letter
    case generateApplication(apiKey: String, request: GenerationRequest)
    
    // CASE 2: Extract Profile from CV (New!)
    case extractProfile(apiKey: String, resumeText: String)
    
    var baseURL: String { "https://api.openai.com" }
    var endPoint: String { "/v1/chat/completions" }
    var action: RestApiAction { .post }
    
    var header: [String : String]? {
        switch self {
        case .generateApplication(let apiKey, _),
             .extractProfile(let apiKey, _):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(apiKey)"
            ]
        }
    }
    
    var body: [String : Any]? {
        switch self {
            
        // LOGIC FOR COVER LETTER
        case .generateApplication(_, let req):
            let systemPrompt = "You are a helpful assistant designed to output JSON. Output ONLY raw JSON with keys: 'subject', 'body', and 'company'."
            let userPrompt = """
            Write a \(req.tone.rawValue) job application email.
            MY NAME: \(req.user.name)
            JOB: \(req.job.title)
            SKILLS: \(req.user.skills)
            EXP: \(req.user.experience)
            DETAILS: \(req.job.cleanDescription.prefix(2000))
            INSTRUCTIONS: \(req.userPrompt)
            TASK:
                1. Identify the Company Name. If inferring from an email domain (e.g. @google.com), use the short name (e.g. 'Google') instead of the full legal entity.
                2. Write a Subject line.
                3. Write the Email Body.
                
                FORMAT: 
                JSON { 
                    "subject": "...", 
                    "body": "...", 
                    "company": "Company Name OR null" 
                }
            """
            return buildOpenAIBody(system: systemPrompt, user: userPrompt, temperature: 0.8)
            
        // LOGIC FOR PROFILE EXTRACTION
        case .extractProfile(_, let resumeText):
            let systemPrompt = """
            You are a Data Extraction API. You will receive a Resume text.
            Extract these fields and return valid JSON:
            - name (Full Name)
            - email
            - phone
            - skills (Comma separated list)
            - experience (Total years string, e.g. '2 Years')
            If not found, use empty string "". Return ONLY raw JSON.
            """
            return buildOpenAIBody(system: systemPrompt, user: resumeText, temperature: 0.1)
        }
    }
    
    // Helper to keep code clean
    private func buildOpenAIBody(system: String, user: String, temperature: Float) -> [String: Any] {
        return [
            "model": "gpt-4.1-mini",
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "temperature": temperature
        ]
    }
    
    func getRequest() -> URLRequest? {
        guard let url = URL(string: baseURL + endPoint) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = action.rawValue
        request.allHTTPHeaderFields = header
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }
}
