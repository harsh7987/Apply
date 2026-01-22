//
//  CVManager.swift
//  Apply
//
//  Created by Pranjal Verma on 07/01/26.
//

import Foundation

class CVManager {
    static let shared = CVManager() // Singleton
    private let fileName = "UserCV.pdf"
    
    // 1. Path to Documents Directory
    private var docURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // 2. The Full Path to the CV
    var cvURL: URL? {
        docURL?.appendingPathComponent(fileName)
    }
    
    // 3. Save Function (Crucial for Phase 2)
    func saveCV(from sourceURL: URL) throws {
        guard let destURL = cvURL else { return }
        
        // Remove old file if it exists (Overwrite)
        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }
        
        // SECURITY SCOPE: Required for accessing files from Files App/iCloud
        let startAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if startAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: destURL)
        print("✅ CV Saved at: \(destURL.path)")
    }
    
    // 4. Check if CV exists (For UI Toggle)
    func cvExists() -> Bool {
        guard let path = cvURL?.path else { return false }
        return FileManager.default.fileExists(atPath: path)
    }
    
    // 5. Delete (If user wants to remove it)
    func deleteCV() {
        guard let url = cvURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
