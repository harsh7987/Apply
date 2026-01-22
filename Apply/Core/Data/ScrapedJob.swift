//
//  ScrapedJob.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

// Core/Data/ScrapedJob.swift
import Foundation

struct ScrapedJob: Identifiable {
    let id = UUID()
    let title: String
    let cleanDescription: String
    let rawDescription: String
    let hrEmail: String?
    let url: String
}
