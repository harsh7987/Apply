//
//  CyberCube.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 30/01/26.
//

import SwiftUI

struct Hero_ElectricMail: View {
    // === ORIGINAL STATES ===
    @State private var energyPulse = false
    
    // === NEW HOLOGRAPHIC STATES ===
    @State private var pulse = false
    @State private var floatData = false
    
    @Environment(\.colorScheme) var colorScheme
    
    // 1. UPDATED BASE COLOR
    // Light Mode: Deep Professional Navy (Darker foundation)
    var electricColor: Color {
        colorScheme == .dark
            ? .cyan
            : Color(red: 0.05, green: 0.1, blue: 0.25) // Deep Navy
    }
    
    var body: some View {
        ZStack {
            
            // ===============================================
            // 1. THE FOUR NEURAL ARMS
            // ===============================================
            ZStack {
                NeuralArm()
                    .rotationEffect(.degrees(180))
                    .offset(y: -80)
                
                NeuralArm()
                    .rotationEffect(.degrees(0))
                    .offset(y: 80)
                
                NeuralArm()
                    .rotationEffect(.degrees(-90))
                    .offset(x: 80)
                
                NeuralArm()
                    .rotationEffect(.degrees(90))
                    .offset(x: -80)
            }
            .opacity(0.9)
            
            // ===============================================
            // 2. THE CENTRAL HOLOGRAPHIC CORE
            // ===============================================
            ZStack {
                // A. THE FLOATING PARTICLES
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.5) : Color.blue.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .offset(x: CGFloat(i * 15 - 15), y: floatData ? -60 : 20)
                            .opacity(floatData ? 0 : 1)
                            .animation(
                                .easeOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                                value: floatData
                            )
                    }
                }
                
                // B. THE GLASS ENVELOPE
                Image(systemName: "envelope.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    // HOLOGRAPHIC GRADIENT FILL
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorScheme == .dark
                            ? [.white.opacity(0.8), .white.opacity(0.2)] // Dark Mode: White Ghost
                            : [Color(red: 0.0, green: 0.35, blue: 1.0).opacity(0.8), Color.blue.opacity(0.4)], // Light Mode: Electric Blue Glass
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    // GLOW
                    .shadow(
                        color: colorScheme == .dark
                        ? Color.blue.opacity(0.4)
                        : Color.blue.opacity(0.3),
                        radius: 20, x: 0, y: 0
                    )
                    .scaleEffect(pulse ? 1.05 : 1.0)
                    .offset(y: pulse ? -5 : 5) // Floating effect
            }
        }
        .frame(height: 350)
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                energyPulse.toggle()
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
            floatData = true
        }
    }
}

// ===============================================
// UPDATED: NEURAL ARM
// Uses the new Deep/Electric contrast logic
// ===============================================
struct NeuralArm: View {
    @State private var flow = false
    @Environment(\.colorScheme) var colorScheme
    
    // UPDATED BASE: Deep Professional Navy
    var electricColor: Color {
        colorScheme == .dark
            ? .cyan
            : Color(red: 0.05, green: 0.1, blue: 0.25) // Deep Navy
    }
    
    // UPDATED HIGHLIGHT: Vivid Electric Blue
    // This is the "Current" running through the wire
    var waveColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 0.0, green: 0.35, blue: 1.0) // Vivid Electric Blue
    }
    
    var body: some View {
        ZStack {
            // ------------------------------------------
            // 1. Background Traces (Dim structure)
            // ------------------------------------------
            FullCircuitShape()
                .stroke(electricColor.opacity(0.15), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 80, height: 100)
            
            // ------------------------------------------
            // 2. MIDDLE FINGER: Static Light (Always ON)
            // ------------------------------------------
            CenterCircuitShape()
                .stroke(
                    LinearGradient(
                        colors: [electricColor.opacity(0.5), waveColor, electricColor],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
                )
                .frame(width: 80, height: 100)
                .shadow(color: waveColor.opacity(0.5), radius: 5) // Subtle glow matching the wave
            
            // ------------------------------------------
            // 3. SIDE FINGERS: Slow Continuous Wave
            // ------------------------------------------
            SideCircuitShape()
                .stroke(
                    LinearGradient(
                        // The waveColor here creates the "Current" effect
                        colors: [electricColor.opacity(0), waveColor, electricColor.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 80, height: 100)
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(y: 1.5)
                        .offset(y: flow ? 120 : -120)
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                flow.toggle()
            }
        }
    }
}

// ===============================================
// SHAPES (Unchanged from your code)
// ===============================================

struct CenterCircuitShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        
        return path
    }
}

struct SideCircuitShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let start = CGPoint(x: width * 0.5, y: 0)
        let split = CGPoint(x: width * 0.5, y: height * 0.3)
        
        // Outer Left
        path.move(to: start); path.addLine(to: split)
        path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.8))
        
        // Inner Left
        path.move(to: start); path.addLine(to: split)
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.8))
        
        // Inner Right
        path.move(to: start); path.addLine(to: split)
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.8))
        
        // Outer Right
        path.move(to: start); path.addLine(to: split)
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.8))
        
        return path
    }
}

struct FullCircuitShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let start = CGPoint(x: width * 0.5, y: 0)
        let split = CGPoint(x: width * 0.5, y: height * 0.3)
        
        // Center
        path.move(to: start)
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        
        // Sides
        path.move(to: start); path.addLine(to: split); path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.6)); path.addLine(to: CGPoint(x: width * 0.1, y: height * 1.2))
        path.move(to: start); path.addLine(to: split); path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.6)); path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.8))
        path.move(to: start); path.addLine(to: split); path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.6)); path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.8))
        path.move(to: start); path.addLine(to: split); path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.6)); path.addLine(to: CGPoint(x: width * 0.9, y: height * 1.2))
        
        return path
    }
}
#Preview {
    Hero_ElectricMail()
        .preferredColorScheme(.dark) // Preview in light mode to check contrast
}

