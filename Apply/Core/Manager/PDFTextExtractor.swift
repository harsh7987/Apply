//
//  PDFTextExtractor.swift
//  Apply
//
//  Created by Pranjal Verma on 07/01/26.
//

import Foundation
import PDFKit

class PDFTextExtractor {
    
    // singleton (optional, but easy to use)
    static let shared = PDFTextExtractor()
    
    // Function: Give me a URL, I give you a String
    func extractText(from url: URL) -> String? {
        
        // 1. Load the PDF Document
        guard let pdfDocument = PDFDocument(url: url) else {
            print("❌ Error: Could not load PDF at \(url)")
            return nil
        }
        
        // 2. Loop through pages and concatenate text
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        for i in 0..<pageCount {
            if let page = pdfDocument.page(at: i) {
                // "string" property extracts readable text from that page
                fullText += page.string ?? ""
            }
        }
        
        // 3. Cleanup (Trimming whitespace)
        let cleanText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanText.isEmpty {
            print("⚠️ Warning: PDF text was empty. Is it an image-based PDF?")
            return nil
        }
        
        print("✅ Success! Extracted \(cleanText.count) characters.")
        return cleanText
    }
}
