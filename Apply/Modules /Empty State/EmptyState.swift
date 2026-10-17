//
//  EmptyState.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 03/02/26.
//

import SwiftUI

struct EmptyStateSchematic: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var scanPhase: CGFloat = -1.0
    
    var body: some View {
        ZStack {
            // Background is transparent so it sits on your existing Home/Drafts BG
            Color.clear
            
            VStack(spacing: 30) {
                
                // 1. SYSTEM STATUS
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .shadow(color: .green, radius: 4)
                    
                    Text("SYSTEM READY // WAITING FOR INPUT")
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(.gray)
                }
                .padding(.bottom, 10)
                
                // 2. THE SCHEMATIC DIAGRAM
                ZStack {
                    // Connecting Lines (Circuitry)
                    Path { path in
                        // Vertical Center Line
                        path.move(to: CGPoint(x: 100, y: 30))
                        path.addLine(to: CGPoint(x: 100, y: 180))
                        
                        // Branching Lines
                        path.move(to: CGPoint(x: 100, y: 60))
                        path.addLine(to: CGPoint(x: 40, y: 60))
                        path.addLine(to: CGPoint(x: 40, y: 80))
                        
                        path.move(to: CGPoint(x: 100, y: 60))
                        path.addLine(to: CGPoint(x: 160, y: 60))
                        path.addLine(to: CGPoint(x: 160, y: 80))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    
                    // NODES
                    VStack(spacing: 40) {
                        
                        // INPUT LAYER
                        HStack(spacing: 40) {
                            SchematicNode(icon: "square.and.arrow.up", label: "SHARE EXT")
                            SchematicNode(icon: "doc.on.clipboard", label: "PASTE LINK")
                        }
                        
                        // PROCESSING LAYER
                        SchematicNode(icon: "cpu.fill", label: "AI ANALYSIS", isActive: true)
                        
                        // OUTPUT LAYER
                        SchematicNode(icon: "envelope.fill", label: "MAIL COMPOSE")
                    }
                }
                .overlay(
                    // The Scanning Laser
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .cyan.opacity(0.5), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 2)
                        .offset(y: scanPhase * 100)
                        .mask(Rectangle().frame(width: 220, height: 200))
                )
                
                // 3. INSTRUCTION TEXT
                VStack(spacing: 12) {
                    Text("Initiate Application Sequence")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Use the Share Sheet from LinkedIn or\npaste a job link to generate a drafted email.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                        .lineSpacing(4)
                }
                
                // 4. MANUAL OVERRIDE NOTE
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Custom Templates available in Settings")
                }
                .font(.caption2)
                .foregroundStyle(.gray.opacity(0.5))
                .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                scanPhase = 1.0
            }
        }
    }
}

// SUB-COMPONENT: SCHEMATIC NODE
struct SchematicNode: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.cyan.opacity(0.1) : Color.gray.opacity(0.05))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isActive ? .cyan : .gray)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isActive ? Color.cyan.opacity(0.5) : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .shadow(color: isActive ? .cyan.opacity(0.3) : .clear, radius: 8)
            
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(isActive ? .cyan : .gray)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmptyStateSchematic()
    }
}
