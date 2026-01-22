//
//  CoverLetterManager.swift
//  Apply
//
//  Created by Pranjal Verma on 22/01/26.
//

import Foundation

class CoverLetterManager {
    static let shared = CoverLetterManager() // Singleton
    private let fileName = "UserCoverLetter.pdf" // 👈 Unique Filename
    
    // 1. Path to Documents Directory
    private var docURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // 2. The Full Path to the Cover Letter
    var coverLetterURL: URL? {
        docURL?.appendingPathComponent(fileName)
    }
    
    // 3. Save Function
    func saveCoverLetter(from sourceURL: URL) throws {
        guard let destURL = coverLetterURL else { return }
        
        // Remove old file if it exists (Overwrite)
        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        
        // SECURITY SCOPE: Required for accessing files
        let startAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if startAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: destURL)
        print("✅ Cover Letter Saved at: \(destURL.path)")
    }
    
    // 4. Check if it exists
    func coverLetterExists() -> Bool {
        guard let path = coverLetterURL?.path else { return false }
        return FileManager.default.fileExists(atPath: path)
    }
    
    // 5. Delete
    func deleteCoverLetter() {
        guard let url = coverLetterURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
