//
//  OpenAIModels.swift
//  ApiCalling
//
//  Created by Pranjal Verma on 04/01/26.
//

import Foundation

struct OpenAIModels: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    // This is actual Json Data which contain subject and body which we are going to extract
    let content: String
}

struct JobLatter: Codable {
    let subject: String
    let body: String
}

struct JobDraft {
    let title: String
    let rawDescription: String
    let cleanDescription: String
    let hrEmail: String?
}



