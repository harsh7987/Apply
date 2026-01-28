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
    
    @State private var showInfoAlert = false
    var viewModel: HomeViewModel
    
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Button {
                    if let urlString = UIPasteboard.general.string {
                        viewModel.scrapeLink(url: urlString)
                    }
                } label: {
                    if viewModel.isScrapingTrue {
                        ProgressView().tint(.black)
                            .whiteCardStyle()
                            .greenCardStyle()
                    } else {
                        Text("\(Image(systemName: "link.circle"))  Paste Link")
                            .font(.title3)
                            .fontWeight(.bold)
                            .greenCardStyle()
                    }
                }
                .disabled(viewModel.isScrapingTrue)
                .opacity(viewModel.isScrapingTrue ? 0.6 : 1.0)
                
                Button {
                    showInfoAlert = true
                    FeedbackManager.shared.impact(.light)
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 50, height: 50)
                        .background(.regularMaterial) // Glass effect
                        .clipShape(Circle())
                }
                .alert("Magic Paste ✨", isPresented: $showInfoAlert) {
                    Button("Got it", role: .cancel) { }
                } message: {
                    Text("Found your dream job? Just copy the link and tap 'Paste'. We will instantly read the job description and write a custom email that matches your skills to their requirements!")
                }
            }
            
        }

    }
    
}

#Preview {
    RoundedButtonView(viewModel: HomeViewModel())
//    ProfileAndSet()
//    HomeTextView()
}
