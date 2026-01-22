//
//  HomeTextView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData

struct HomeTextView: View {
    @Query var users: [UserProfile]
    var body: some View {
        VStack(alignment: .leading) {
            
            var greetingMessage: String {
                let hour = Calendar.current.component(.hour, from: Date())
                
                switch hour {
                case 5..<12:
                    return "Good Morning"
                case 12..<17:
                    return "Good Afternoon"
                case 17..<22:
                    return "Good Evening"
                default:
                    return "Hello" // Late night fallback
                }
            }
            
            if let user = users.first {
                Text("\(greetingMessage), \(user.name).")
                    .largeBoldTitle2()
            } else {
                Text("Hello.")
                    .largeBoldTitle2()
            }
            
            Text("Ready for the next opportunity?")
                .homeSubHeadline()
        }
        .padding(.top)
        .frame(maxWidth: .infinity, alignment: .leading).padding()
    }
}

struct RoundedButtonView: View {
    @State private var scrapedJob: ScrapedJob? = nil
    @State private var isScraping = false
    
    var body: some View {
        VStack {
            // 1. Share Post Button
            Button {
                // This will eventually be triggered by the Share Extension
            } label: {
                Text("\(Image(systemName: "link"))  Create from share post")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .greenCardStyle()
            }
            
            HStack {
                // 2. Paste Link Button
                Button {
                    // Grab from clipboard automatically!
                    if let urlString = UIPasteboard.general.string {
                        scrapeLink(url: urlString)
                    }
                } label: {
                    if isScraping {
                        ProgressView().tint(.black)
                            .whiteCardStyle()
                            .glossyCardBg(radius: 40)
                    } else {
                        Text("\(Image(systemName: "link.circle"))  Paste Link")
                            .whiteCardStyle()
                            .glossyCardBg(radius: 40)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .disabled(isScraping)
                
                // 3. Import / Manual Button
                Button {
                    // Manual entry logic
                } label: {
                    Text("\(Image(systemName:"clipboard"))  Import")
                        .whiteCardStyle()
                        .glossyCardBg(radius: 40)
                }
            }
        }
        // 4. The Sheet that triggers when scrapedJob is set
        .sheet(item: $scrapedJob) { job in
            JobPreviewView(job: job)
        }
    }
    
    func scrapeLink(url: String) {
        print("🚀 Starting Scrape for: \(url)")
        self.isScraping = true
        
        Task { @MainActor in
            JobScraperManager.shared.scrape(url: url) { job in
                self.isScraping = false
                
                if let job = job {
                    print("✨ RECEIVED JOB: \(job.title)")
                    self.scrapedJob = job
                } else {
                    print("⚠️ Scrape Failed")
                    // Optional: Add a state for an alert here
                }
            }
        }
    }
}

#Preview {
    RoundedButtonView()
//    ProfileAndSet()
//    HomeTextView()
}
