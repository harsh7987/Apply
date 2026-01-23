//
//  JobScraperManager.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

// Core/Manager/JobScraperManager.swift
import Foundation
import WebKit

@MainActor // ⚠️ Crucial: WebKit must run on Main Thread
class JobScraperManager: NSObject, WKNavigationDelegate {
    
    static let shared = JobScraperManager()
    
    private var webView: WKWebView!
    private var onCompletion: ((ScrapedJob?) -> Void)?
    private var currentUrl: String = ""
    
    override private init() {
        super.init()
        let config = WKWebViewConfiguration()
        // Your Mobile User Agent (Perfect for LinkedIn)
        config.applicationNameForUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.navigationDelegate = self
    }
    
    func scrape(url: String, completion: @escaping (ScrapedJob?) -> Void) {
        print("🌍 Scraper Starting for: \(url)")
        self.currentUrl = url
        self.onCompletion = completion
        
        guard let link = URL(string: url) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }
        
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    func scrapeAsync(url: String) async -> ScrapedJob? {
        // This "pauses" and waits for your completion handler to finish
        return await withCheckedContinuation { continuation in
            // Call your existing function
            self.scrape(url: url) { result in
                // Resume the async wait with the result
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ Page Loaded. Waiting 1.5 seconds for JS...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.runExtractionScript()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("❌ Web Load Error: \(error.localizedDescription)")
        onCompletion?(nil)
    }
    
    // MARK: - JavaScript Injection
    private func runExtractionScript() {
        // (This is your EXACT JS Script)
        let jsScript = """
            (function() {
                var seeMoreBtn = document.querySelector('.feed-shared-inline-show-more-text__see-more-less-toggle') || 
                                 document.querySelector('.show-more-less-html__button');
                if (seeMoreBtn) { seeMoreBtn.click(); }

                var title = document.title;
                var desc = "";
                
                var postText = document.querySelector('.update-components-text') || 
                               document.querySelector('.feed-shared-update-v2__commentary');
                var jobText = document.querySelector('.description__text') || 
                              document.querySelector('.jobs-description-content__text');
                var articleText = document.querySelector('article');

                if (postText) { desc = postText.innerText; }
                else if (jobText) { desc = jobText.innerText; }
                else if (articleText) { desc = articleText.innerText; }
                else { desc = document.body.innerText; }
                
                return { "title": title, "description": desc };
            })();
        """
        
        webView.evaluateJavaScript(jsScript) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let dict = result as? [String: String] {
                let title = dict["title"] ?? "Unknown"
                let rawDesc = dict["description"] ?? ""
                
                print("🎯 JS SCRAPER SUCCESS! processing text...")
                self.processResults(title: title, rawDesc: rawDesc)
            } else {
                print("❌ JS Error or No Data: \(String(describing: error))")
                self.onCompletion?(nil)
            }
        }
    }
    
    // MARK: - Processing Logic
    private func processResults(title: String, rawDesc: String) {
        // 1. Clean Text
        let cleanDesc = cleanJobDescription(rawDesc)
        
        // 2. Extract Email (Using your Nuclear Hunter)
        let email = extractEmail(from: cleanDesc)
        
        // 3. Create Model
        let job = ScrapedJob(title: title,
                             cleanDescription: cleanDesc,
                             rawDescription: rawDesc,
                             hrEmail: email,
                             url: self.currentUrl)
        
        // 4. Return Result
        print("📦 Job Packaged. Title: \(title)")
        print("Job Description Starts -----------------------> ")
        print("📦 Job Packaged. Description: \(cleanDesc)")
        print("Job Description Ends ------------------------> ")
        if let email = email { print("📧 Found Email: \(email)") }
        
        self.onCompletion?(job)
    }
    
    // MARK: - Utilities (Your Logic)
    private func cleanJobDescription(_ text: String) -> String {
        var clean = text
        if let range = clean.range(of: "Skip to main content") {
            clean = String(clean[range.upperBound...])
        }
        let topJunk = ["Sign in", "Join for free", "LinkedIn"]
        for junk in topJunk {
            clean = clean.replacingOccurrences(of: junk, with: "")
        }
        
        let lines = clean.components(separatedBy: .newlines)
        var keptLines: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed == "Like" || trimmed == "Comment" || trimmed == "Share" { break }
            if trimmed == "See more comments" || trimmed.contains("To view or add a comment") { break }
            
            let isNumber = Int(trimmed) != nil
            let isCommentStat = trimmed.hasSuffix("Comments") && trimmed.count < 20
            let isReactionStat = trimmed.hasSuffix("Reactions")
            
            if isNumber || isCommentStat || isReactionStat { continue }
            keptLines.append(line)
        }
        return keptLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractEmail(from text: String) -> String? {
        let greedyPattern = "\\S+@\\S+"
        do {
            let regex = try NSRegularExpression(pattern: greedyPattern)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            
            for match in results {
                let rawCandidate = nsString.substring(with: match.range)
                var cleanCandidate = rawCandidate.trimmingCharacters(in: CharacterSet(charactersIn: ".,()[]!;:'\""))
                cleanCandidate = cleanCandidate.precomposedStringWithCompatibilityMapping // 🛡️ NFKC
                cleanCandidate = cleanCandidate.lowercased()
                
                if isValidEmail(cleanCandidate) { return cleanCandidate }
            }
        } catch { print("Regex Error: \(error)") }
        return nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
