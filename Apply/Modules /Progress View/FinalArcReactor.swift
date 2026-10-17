//
//  FinalArcReactor.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 01/02/26.
//

import SwiftUI
internal import Combine

struct HolographicProcessingView: View {
    // 1. NARRATIVE STEPS
    let processingSteps = [
        "Initializing Neural Core...",
        "Scanning Job Architecture...",
        "Extracting Key Patterns...",
        "Synthesizing Professional Tone...",
        "Compiling Magic Draft..."
    ]
    
    // 2. STATE VARIABLES
    @State private var currentStepIndex = 0
    @State private var rotateOuter = false
    @State private var rotateInner = false
    @State private var floatData = false
    @State private var pulseCore = false
    
    // Timer for text changes
    @State private var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // A. BACKGROUND (Deep Focus Mode)
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
                // Ambient Glow
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .blur(radius: 100)
                    .scaleEffect(1.2)
            } else {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .blur(radius: 100)
            }
            
            VStack(spacing: 50) {
                
                // B. THE HOLOGRAPHIC REACTOR
                ZStack {
                    
                    // 1. FLOATING DATA PARTICLES (Behind the Core)
                    ZStack {
                        ForEach(0..<4) { i in
                            Circle()
                                .fill(colorScheme == .dark ? Color.cyan.opacity(0.5) : Color.blue.opacity(0.4))
                                .frame(width: 4, height: 4)
                                // Randomize start positions slightly
                                .offset(x: CGFloat(i * 12 - 18), y: floatData ? -70 : 10)
                                .opacity(floatData ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 2.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.4),
                                    value: floatData
                                )
                        }
                    }
                    
                    // 2. THE BROKEN TECH RING (The "Ask Myra" Spectrum)
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    .cyan, .blue, .purple, .pink, .cyan
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [4, 12])
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(rotateOuter ? 360 : 0))
                    
                    // 3. THE ORBITAL SATELLITE (High Speed Indicator)
                    Circle()
                        .strokeBorder(Color.clear, lineWidth: 1)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle() // The Dot
                                .fill(
                                    LinearGradient(colors: [.cyan, .white], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 8, height: 8)
                                .shadow(color: .cyan.opacity(0.8), radius: 5)
                                .offset(y: -50) // Push to edge
                        )
                        .rotationEffect(.degrees(rotateInner ? 360 : 0))
                    
                    // 4. THE CENTER CORE (Holographic Sparkles)
                    Image(systemName: "sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: colorScheme == .dark
                                ? [.white, .purple.opacity(0.5)]
                                : [.blue, .cyan.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        // Inner Glow
                        .shadow(
                            color: colorScheme == .dark
                            ? Color.purple.opacity(0.6)
                            : Color.blue.opacity(0.4),
                            radius: 15, x: 0, y: 0
                        )
                        .scaleEffect(pulseCore ? 1.1 : 0.95)
                    
                }
                .onAppear {
                    // Trigger Animations
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotateOuter = true
                    }
                    withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                        rotateInner = true
                    }
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulseCore = true
                    }
                    floatData = true
                }
                
                // C. THE NARRATIVE TEXT
                VStack(spacing: 12) {
                    Text(processingSteps[currentStepIndex])
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        // Smooth text morph
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStepIndex)
                        .multilineTextAlignment(.center)
                    
                    Text("Constructing your application...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 30)
            }
        }
        // D. TEXT LOOP LOGIC
        .onReceive(timer) { _ in
            if currentStepIndex < processingSteps.count - 1 {
                currentStepIndex += 1
            } else {
                timer.upstream.connect().cancel()
            }
        }
    }
}

#Preview {
    HolographicProcessingView()
}
