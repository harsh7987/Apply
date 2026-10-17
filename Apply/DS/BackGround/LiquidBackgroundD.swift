//
//  LiquidBackgroundD.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 29/01/26.
//

import SwiftUI


struct LiquidDarkBackground: View {
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    // VARIANT 2 = "Midnight Tyndall" (The new Lumy Space look)
    let variant: Int
    
    var body: some View {
        ZStack {
            // 1. BASE LAYER
            if colorScheme == .light {
                Color(red: 0.96, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
            } else {
                // DARK MODE VARIANTS
                if variant == 1 {
                    // "The Eclipse" (Gold/Black)
                    LinearGradient(
                        colors: [Color(red: 0.02, green: 0.02, blue: 0.05), Color(red: 0.1, green: 0.08, blue: 0.05)],
                        startPoint: .top, endPoint: .bottom
                    ).ignoresSafeArea()
                } else if variant == 2 {
                    Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
                } else {
                    Color(red: 0.03, green: 0.03, blue: 0.04).ignoresSafeArea()
                }
            }
        }
        // 2. ATMOSPHERIC OVERLAY (The Tyndall Effect)
        .overlay(
            ZStack {
                // --- LIGHT MODE ORBS ---
                ZStack {
                    OrbView(color: Color(red: 1.0, green: 0.85, blue: 0.6).opacity(0.5), size: 400, x: -100, y: -100, animate: animate)
                    OrbView(color: Color(red: 0.7, green: 0.85, blue: 0.95).opacity(0.5), size: 400, x: 100, y: 200, animate: animate)
                    OrbView(color: Color.white.opacity(0.7), size: 300, x: 50, y: -50, animate: animate)
                }
                .opacity(colorScheme == .light ? 1 : 0)
                
                // --- DARK MODE ORBS ---
                ZStack {
                    if variant == 1 {
                        OrbView(color: Color(red: 1.0, green: 0.6, blue: 0.6).opacity(0.15), size: 500, x: 0, y: 350, animate: animate)
                        OrbView(color: Color(red: 0.1, green: 0.1, blue: 0.3).opacity(0.2), size: 400, x: -100, y: -200, animate: animate)
                    } else if variant == 2 {
                        // Orb 1: The Warmth (Gold/Amber)
                        OrbView(
                            color: Color(red: 0.6, green: 0.4, blue: 0.0).opacity(0.3),
                            size: 400,
                            x: 0,
                            y: 50,
                            animate: false
                        )
                        
                        // 2. The Aurora (Target: x: 0, y: 200)
                        // We pass y: -200 so that (-200 * -1) results in 200
                        OrbView(
                            color: Color(red: 0.1, green: 0.2, blue: 0.5).opacity(0.4),
                            size: 400,
                            x: 0,
                            y: -200,
                            animate: false
                        )
                        
                        // 3. The Starlight (Target: x: 50, y: -50)
                        // We pass inverted values for both x and y
                        OrbView(
                            color: Color.blue.opacity(0.1),
                            size: 300,
                            x: -50,
                            y: 50,
                            animate: false
                        )
                    } else {
                        OrbView(color: Color.white.opacity(0.1), size: 600, x: 0, y: 0, animate: animate)
                    }
                }
                .opacity(colorScheme == .dark ? 1 : 0)
            }
        )
        // 3. LOCKS
        .clipped()
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// Helper View
struct OrbView: View {
    var color: Color
    var size: CGFloat
    var x: CGFloat
    var y: CGFloat
    var animate: Bool
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 110) // Increased blur for "Foggy" Tyndall look
            .offset(x: animate ? x : x * -1, y: animate ? y : y * -1)
    }
}

#Preview {
    LiquidDarkBackground( variant: 2)
        .environment(\.colorScheme, .dark)
}



