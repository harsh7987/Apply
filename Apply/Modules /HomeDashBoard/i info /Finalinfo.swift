//
//  Finalinfo.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 30/01/26.
//

import SwiftUI
struct InfoButtonTesting2: View {
    // This controls the pop-up sheet
    @State private var showInfoSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            VStack(spacing: 50) {
            
                VStack {
                    InfoButton_Gem1 { showInfoSheet.toggle() }
                }
            }
        .sheet(isPresented: $showInfoSheet) {
            InfoSheetContent2()
                .presentationDetents([.fraction(0.4)]) // Takes up 40% of screen
                .presentationDragIndicator(.visible)
        }
    }
}


struct InfoButton_Gem1: View {
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "info")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                // Light Mode: Dark Blue for contrast
                // Dark Mode: Pure White
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.0, green: 0.3, blue: 0.8))
                .frame(width: 22, height: 22)
                .background(
                    ZStack {
                        // 1. BASE LAYER
                        // Dark Mode: Uses your ORIGINAL opacity (0.4) for that deep crystal look
                        // Light Mode: Uses the NEW opacity (0.9) so it's not transparent
                        Circle()
                            .fill(colorScheme == .dark ? Color.black.opacity(0.4) : Color.white.opacity(0.9))
                        
                        // 2. MATERIAL LAYER
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                )
                .overlay(
                    // 3. THE BEZEL (Hybrid Logic)
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: colorScheme == .dark
                                // DARK MODE: Your ORIGINAL Sharp Diamond Gradient
                                ? [.white, .white.opacity(0.0), .white.opacity(0.5)]
                                // LIGHT MODE: The New Subtle Grey Gradient (for visibility)
                                : [.black.opacity(0.1), .white.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                // 4. THE SHINE (Light Mode Only - Extra Gloss)
                .overlay(
                    colorScheme == .light ?
                    Circle()
                        .fill(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom))
                        .frame(width: 20, height: 20)
                        .blur(radius: 3)
                        .offset(x: -2, y: -2)
                        .opacity(0.6)
                    : nil
                )
                // 5. SHADOW (Lift)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.blue.opacity(0.15),
                    radius: 4, x: 0, y: 1
                )
        }
        .contentShape(Circle()) // Ensures the button is clickable
    }
}

struct InfoSheetContent2: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()
            }
            
            VStack(spacing: 20) {
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                
                Text("How to use")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Simply copy a job link from LinkedIn or Indeed, then tap the gold 'Paste Link' button. We'll handle the rest!")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ZStack {
        LiquidDarkBackground(variant: 1)
            .environment(\.colorScheme, .dark)
        InfoButtonTesting2()
    }
}
