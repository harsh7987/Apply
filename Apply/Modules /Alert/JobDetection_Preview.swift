//
//  JobDetection_Preview.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 31/01/26.
//

import SwiftUI

// ==========================================
// PREVIEWER (Final Test)
// ==========================================
struct JobDetection_Preview: View {
    @State private var showCard = true
    @State private var blurBackground = true
    
    // This will be dynamic in your real app
    let testURL = "https://www.linkedin.com/jobs/view/3819402..."
    
    var body: some View {
        ZStack {
            // Background
            LiquidDarkBackground(variant: 1)
                .blur(radius: blurBackground ? 10 : 0)
            
            // The Intercept Card
            if showCard {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { closeCard() }
                
                JobInterceptCard(url: testURL, onApply: {
                    print("Generating Application for \(testURL)")
                    closeCard()
                }, onDismiss: {
                    closeCard()
                })
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .zIndex(3)
            }
        }
    }
    
    func closeCard() {
        withAnimation {
            showCard = false
            blurBackground = false
        }
        // For preview purposes, bring it back after 3 seconds so you can see it again
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showCard = true
                blurBackground = true
            }
        }
    }
}

// ==========================================
// THE SMART INTERCEPT CARD (Logic + UI)
// ==========================================
struct JobInterceptCard: View {
    let url: String
    var onApply: () -> Void
    var onDismiss: () -> Void
    
    @State private var pulse = false
    @Environment(\.colorScheme) var colorScheme
    
    // --- SMART LOGIC ---
    
    var platformName: String {
        let lower = url.lowercased()
        if lower.contains("linkedin") { return "LinkedIn" }
        if lower.contains("indeed") { return "Indeed" }
        if lower.contains("glassdoor") { return "Glassdoor" }
        if lower.contains("naukri") { return "Naukri" }
        return "Web Link"
    }
    
    var themeColor: Color {
        let lower = url.lowercased()
        if lower.contains("linkedin") { return Color.blue }
        if lower.contains("indeed") { return Color.indigo }
        if lower.contains("glassdoor") { return Color.green }
        if lower.contains("naukri") { return Color.orange }
        return Color.gray
    }
    
    var platformIcon: String {
        let lower = url.lowercased()
        if lower.contains("linkedin") { return "link" }
        if lower.contains("indeed") { return "arrow.up.right.circle" }
        if lower.contains("glassdoor") { return "door.left.hand.open" }
        return "globe"
    }
    
    // --- UI VARIABLES ---
    
    var cardBackground: Material {
        colorScheme == .dark ? .ultraThin : .regular
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var subTextColor: Color {
        colorScheme == .dark ? .gray : .gray
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 1. Animated Icon Header
            ZStack {
                // Pulsing rings
                Circle()
                    .stroke(LinearGradient(colors: [themeColor.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .opacity(pulse ? 0 : 1)
                
                // Icon Background
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                // Smart Icon
                Image(systemName: platformIcon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(themeColor)
                    .symbolEffect(.bounce, value: pulse)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
            
            // 2. Text Content
            VStack(spacing: 6) {
                Text("New Job Detected")
                    .font(.title3.bold())
                    .foregroundStyle(textColor)
                
                Text("Analyzing parameters from source:")
                    .font(.caption)
                    .foregroundStyle(subTextColor)
                
                // Smart Badge
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.caption2)
                    Text(platformName)
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(themeColor.opacity(0.15))
                .foregroundStyle(themeColor)
                .clipShape(Capsule())
                .padding(.top, 4)
            }
            
            // 3. Action Buttons
            HStack(spacing: 12) {
                // Ignore
                Button(action: onDismiss) {
                    Text("Ignore")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                        )
                }
                
                // Generate
                Button(action: onApply) {
                    Text("Generate")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 10)
        }
        .padding(24)
        .frame(width: 320)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(cardBackground)
                
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.85))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: colorScheme == .dark ? [.white.opacity(0.2), .clear] : [.black.opacity(0.05), .black.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.5) : .black.opacity(0.15),
            radius: 30, x: 0, y: 10
        )
    }
}

// Background Helper
struct LiquidDarkBackground2: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
                Circle().fill(Color.blue.opacity(0.3)).blur(radius: 120).offset(x: -100, y: -200)
                Circle().fill(Color.purple.opacity(0.3)).blur(radius: 120).offset(x: 100, y: 200)
            } else {
                Color.white.ignoresSafeArea()
                Circle().fill(Color.blue.opacity(0.1)).blur(radius: 120).offset(x: -100, y: -200)
                Circle().fill(Color.orange.opacity(0.1)).blur(radius: 120).offset(x: 100, y: 200)
            }
        }
    }
}

#Preview {
    JobDetection_Preview()
}
