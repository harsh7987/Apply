//
//  ApiRest.swift
//  ApiCalling
//
//  Created by Pranjal Verma on 04/01/26.
//

import Foundation

enum RestApiAction: String {
    case get = "GET"
    case post = "POST"
}

enum UserTone {
    case formal
    case casual
    case hrFriendly
}

protocol NetworkRequest {
    var baseURL: String { get }
    var endPoint: String { get }
    var header: [String : String]? { get }
    var action: RestApiAction { get }
    var body: [String : Any]? { get }
    func getRequest() -> URLRequest?
}

enum RestApi: NetworkRequest {
    
    case generateApplication(apiKey: String, jobDetails: String, skills: String, experince: String, userTone: UserTone, name: String)
    
    var baseURL: String {
        switch self {
        case .generateApplication(let apiKey, let jobDetails, let skills, let experince, _, _):
            "https://api.openai.com"
        }
    }
    
    var endPoint: String {
        switch self {
        case .generateApplication(let apiKey, let jobDetails, let skills, let experince, _, _):
            "/v1/chat/completions"
        }
    }
    
    var header: [String : String]? {
        switch self {
        case .generateApplication(let apiKey, let jobDetails, let skills, let experince, _, _):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(apiKey)"
            ]
        }
    }
    
    var action: RestApiAction {
        switch self {
        case .generateApplication(let apiKey, let jobDetails, let skills, let experince, _, _):
                .post
        }
    }
    
    var body: [String : Any]? {
        switch self {
        case .generateApplication(let apiKey, let jobDetails, let skills, let experince, let userTone, let name):
            let systemPrompt = "You are a helpful assistant designed to output JSON. You must ONLY output a raw JSON object with keys: 'subject' and 'body'. Do not add any markdown formatting or extra text."
            
            var userType: String {
                switch userTone {
                case .formal:
                    "FORMAL"
                case .casual:
                    "CASUAL"
                case .hrFriendly:
                    "HR FRIENDLY"
                }
            }
            
            let userPrompt = """
                Write a professional job application email based on this data:
                MY NAME: \(name)
                JOB DETAILS: \(jobDetails)
                MY SKILLS: \(skills)
                MY EXPERINCE: \(experince)
                
                REQUIREMENT: 
                - TYPE OF TONE: \(userType)
                - FORMATE: Professional Cover Letter
                - Response strictly in JSON format: {"subject": "...", "body": "..."}
                """
            
            return [
                "model": "gpt-4.1-mini",
                "response_format": ["type": "json_object"],
                "messages": [
                    // message 1 (system)
                    ["role" : "system", "content": systemPrompt],
                    // meessage 2 (user)
                    ["role" : "user", "content" : userPrompt]
                ]
            ]
        }
    }
    
    func getRequest() -> URLRequest? {
        guard let url = URL(string: baseURL + endPoint) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = action.rawValue
        request.allHTTPHeaderFields = header
        
        if let body = body {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error converting dictionary to json data \(error)")
                return nil
            }
        }
        
        return request
    }
    
    
}
