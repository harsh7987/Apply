//
//  HomeTextView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData

struct HomeTextView: View {
    // 1. DATA CONNECTION
    @Query var users: [UserProfile]
    @Environment(\.colorScheme) var colorScheme
    @State private var shimmer = false
    
    // 2. LOGIC
    var userName: String {
        users.first?.name ?? "Architect" // Fallback if no user exists
    }
    
    var firstName: String {
        userName.components(separatedBy: " ").first ?? userName
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // A. THE GREETING (Clean & Simple)
            Text(getGreeting())
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            
            // B. THE NAME (Liquid Gold Effect)
            Text(firstName)
                .font(.system(size: 46, weight: .heavy, design: .rounded)) // Heavy font for impact
                .tracking(-1) // Tight styling
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                // The Masking Magic
                .overlay(
                    // LIQUID GRADIENT (Breathing Animation)
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.7, blue: 0.0), Color(red: 1.0, green: 0.4, blue: 0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text(firstName)
                            .font(.system(size: 46, weight: .heavy, design: .rounded))
                            .tracking(-1)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    )
                )
                // Hide the original text so only the gradient shows
                .foregroundStyle(.clear)
                // The Glow
                .shadow(
                    color: colorScheme == .dark
                        ? Color.orange.opacity(0.4) // Neon Glow in Dark Mode
                        : Color.black.opacity(0.05), // Soft Shadow in Light Mode
                    radius: 12, x: 0, y: 5
                )

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24) // Matches your other views
        .padding(.top, 20)
        .onAppear {
            // This makes the gold flow back and forth
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                shimmer.toggle()
            }
        }
    }
    
    // HELPER: Time Logic
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<22: return "Good Evening,"
        default: return "Hello,"
        }
    }
}


// Home Header
struct HomeHead: View {
    // Receive data from HomeView
    var manager: CreditManager
    @Binding var showSubscription: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            HomeTextView()
                
                Spacer() // Pushes the button to the far right
                
                TokenTriggerButton(manager: manager, showSubscription: $showSubscription)
                .padding(.top, 22)      // Matches the top padding inside HomeHeader
                .padding(.trailing, 24) // Aligns with the right edge of the screen

        }
        .padding(.top, 10)
        .padding(.bottom, 50)     // Space before the cards
    }
    
}



// Liquid Button
struct RoundedButtonView: View {
    @State private var showInfoAlert = false
    var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            // THE GOD LEVEL BUTTON
            LiquidDarkButton(
                title: "Paste Link",
                icon: "link",
                isLoading: viewModel.isScrapingTrue, // 👈 Pass logic here
                action: {
                    // 👈 YOUR LOGIC HERE
                    if let urlString = UIPasteboard.general.string {
                        viewModel.scrapeLink(url: urlString)
                    } else {
                        // Optional: Handle empty clipboard feedback here
                        print("Clipboard is empty")
                    }
                }
            )
        }
    }
}

struct LiquidDarkButton: View {
    var title: String = "Paste Link"
    var icon: String = "link"
    var isLoading: Bool = false // 👈 Added Loading State
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 1. LOADING STATE
                if isLoading {
                    ProgressView()
                        .tint(.black) // Black spinner matches the text color
                        .scaleEffect(1.2)
                }
                // 2. NORMAL STATE
                else {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .foregroundColor(.black.opacity(0.85)) // Contrast Text
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // LIQUID CORE (Platinum Gold)
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.35),
                                    Color(red: 1.0, green: 0.65, blue: 0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // INNER GLOW
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.9), .white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .padding(1)
                    
                    // DEPTH SHADOW
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.15), lineWidth: 4)
                        .blur(radius: 4)
                        .offset(y: 4)
                        .mask(RoundedRectangle(cornerRadius: 40, style: .continuous))
                }
            )
            // OUTER GLOW
            .shadow(
                color: colorScheme == .dark
                ? Color(red: 1.0, green: 0.7, blue: 0.1).opacity(0.3)
                : Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.4),
                radius: colorScheme == .dark ? 20 : 15,
                x: 0,
                y: colorScheme == .dark ? 0 : 10
            )
            .overlay(
                // REFLECTION
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(.white.opacity(0.35))
                    .frame(height: 35)
                    .mask(
                        VStack {
                            Circle()
                                .frame(width: 350, height: 120)
                                .offset(y: -45)
                                .blur(radius: 15)
                            Spacer()
                        }
                    )
                    .blendMode(.overlay)
            )
        }
        // Safety Padding
        .padding(.horizontal, 20)
        // Disable interaction while loading
        .disabled(isLoading)
        // Slight opacity fade when loading
        .opacity(isLoading ? 0.8 : 1.0)
        .animation(.easeInOut, value: isLoading)
    }
}

#Preview {
    RoundedButtonView(viewModel: HomeViewModel())
//    ProfileAndSet()
//    HomeTextView()
//    @State var showSubscription = false
//    HomeHead(manager: CreditManager(), showSubscription: $showSubscription)
}
